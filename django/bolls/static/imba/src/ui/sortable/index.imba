import {
	attachClosestEdge,
	extractClosestEdge,
} from '@atlaskit/pragmatic-drag-and-drop-hitbox/closest-edge';
import { getReorderDestinationIndex } from '@atlaskit/pragmatic-drag-and-drop-hitbox/util/get-reorder-destination-index';
import {
	draggable,
	dropTargetForElements,
	monitorForElements,
} from '@atlaskit/pragmatic-drag-and-drop/element/adapter';
import type { ElementDropTargetEventBasePayload } from '@atlaskit/pragmatic-drag-and-drop/element/adapter';
import { reorderWithEdge } from '@atlaskit/pragmatic-drag-and-drop-hitbox/util/reorder-with-edge';

import { DropIndicator } from './drop-indicator';


###
Usage Example

```imba
tag app
	@observable list = [
		{ id: 'melon', name: 'melon' }
		{ id: 'garlic', name: 'garlic' }
		{ id: 'onion', name: 'onion' }
		{ id: 'paper', name: 'paper' }
		{ id: 'salt', name: 'salt' }
		{ id: 'tomato', name: 'tomato' }
		{ id: 'olive-oil', name: 'olive oil' }
		{ id: 'apple', name: 'apple' }
		{ id: 'peach', name: 'peach' }
		{ id: 'pineapple', name: 'pineapple' }
		{ id: 'spinach', name: 'spinach' }
		{ id: 'potato', name: 'potato' }
		{ id: 'carrot', name: 'carrot' }
		{ id: 'peanut', name: 'peanut' }
	]

	@autorun
	def listChanged
		log("list changed", list)

	css
		$flush: blue4/40

	<self>
		<sortable bind=list idKey="id" namespace="sortable">
			for item, index in list
				<sortable-li id=item.id key=item.id item=item>
					item.name
					<input type="text" bind=item.name [c:inherit bg:transparent b:none p:1 ml:2 w:100%]> 
					<button[ml:auto bg:blue1/20 @active:blue2/10 p:1 2] @click=(log "clicked", id)> "idc"
					<input type="checkbox" bind=item.done>
```
###
tag sortable
	prop data\Array<any>
	prop idKey = "id"
	prop namespace = "sortable"

	# computed because this should not change == even if the `{namespace}-item` string is the same, the Symbol of `{namespace}-item` will be unique every time you generate it even if the namespace is the same
	@computed get itemKey
		return Symbol(`{namespace}-item`);

	def getItemIDByIDKey(item, key)
		# the key may be a chained key like "id.value" so we need to resolve it
		const keys = key.split('.').reduce(&, item) do(acc, part) acc && acc[part];
		return keys

	def getItemData(item)
		return { [itemKey]: true, id: getItemIDByIDKey(item, idKey), item };

	def isItemData(data\Record<string | symbol, unknown>)
		return data[itemKey] === true;


	def mount
		#cleanupMonitor = monitorForElements({
			canMonitor: do({ source }) isItemData(source.data),
			onDrop: do({ location, source })
				const target = location.current.dropTargets[0];
				if !target
					return

				const sourceData = source.data;
				const targetData = target.data;
				if !isItemData(sourceData) || !isItemData(targetData)
					return

				const indexOfSource = data.findIndex(do(item) getItemIDByIDKey(item, idKey) === sourceData.id);
				const indexOfTarget = data.findIndex(do(item) getItemIDByIDKey(item, idKey) === targetData.id);
				if indexOfTarget < 0 || indexOfSource < 0
					return

				const closestEdgeOfTarget = extractClosestEdge(targetData);

				const finishIndex = getReorderDestinationIndex({
					startIndex: indexOfSource,
					indexOfTarget,
					closestEdgeOfTarget,
					axis: 'vertical',
				})
				if finishIndex === indexOfSource
					return

				data = reorderWithEdge({
					list: data,
					startIndex: indexOfSource,
					indexOfTarget,
					closestEdgeOfTarget,
					axis: 'vertical',
				})
				emit("sorted", data)

				await imba.commit!

				if source.element instanceof HTMLElement
					source.element.animate([{ backgroundColor: "var(--acc-bgc-hover, transparent)" }, {}], {
						duration: 1000,
						easing: 'cubic-bezier(0.25, 0.1, 0.25, 1.0)',
						iterations: 1,
					});
		})
	
	def unmount
		#cleanupMonitor()
	
	<self[p:0]>
		<slot>


const idle = { type: "idle", closestEdge: null };
const isDragging = { type: "is-dragging", closestEdge: null };
const isDraggingOver = { type: "is-dragging-over", closestEdge: null }; # example of a state with additional data


tag sortable-li
	prop item

	state = idle

	def onDragChange event\ElementDropTargetEventBasePayload
		const isSource = event.source.element === self;
		if isSource
			return;

		const closestEdge = extractClosestEdge(event.self.data);

		const isItemBeforeSource = event.source.element === nextElementSibling;
		const isItemAfterSource = event.source.element === previousElementSibling;

		const isDropIndicatorHidden =
			(isItemBeforeSource && closestEdge === 'bottom') or (isItemAfterSource && closestEdge === 'top');

		if isDropIndicatorHidden
			state.closestEdge = null;
		else
			state = { type: 'is-dragging-over', closestEdge }

		imba.commit!

	get parent\(typeof sortable)
		closest('sortable-tag')

	def mount
		const data = parent.getItemData(item);
		#cleanupDraggable = draggable({
			element: self,
			getInitialData: do(event)
				return data

			onDragStart: do(event)
				self.state = isDragging
				imba.commit!

			onDrop: do(event)
				self.state = idle
				imba.commit!
		})

		#cleanupDropTargetForElements = dropTargetForElements({
			element: self,

			canDrop: do({ source }) source.element !== self && parent.isItemData(source.data),

			getData: do({ input })
				return attachClosestEdge(data, {
					element: self,
					input,
					allowedEdges: ['top', 'bottom'],
				});

			getIsSticky: do true

			onDragEnter: onDragChange.bind(self),
			onDrag: onDragChange.bind(self),

			onDragLeave: do
				state = idle
				imba.commit!

			onDrop: do
				state = idle
				imba.commit!
		})
	
	def unmount
		#cleanupDraggable && #cleanupDraggable()
		#cleanupDropTargetForElements && #cleanupDropTargetForElements()

	<self[pos:relative] [o:0.5]=(state === isDragging)>
		# <svg[cursor:grab @active:grabbing fill:currentColor o:0.5 mr:1] src=ICONS.DOTS_SIX width="1rem" /> # out of box handle, but sometimes we want the handle to be deeper in the tree, and anyway we use entire item as the handle
		<slot>
		if state.type === 'is-dragging-over' && state.closestEdge
			<DropIndicator edge=state.closestEdge gap="0rem">
