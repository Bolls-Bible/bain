import {svg_paths} from "./svg_paths.imba"
import './search-text-as-html.imba'
import Sortable from 'sortablejs';

tag orderable-list
	prop list = []
	#swapped_offset = 0
	#dy = 0
	#scroll_direction = 0
	#initial_parent_scroll = 0

	def mount
		#sortable = new Sortable(self, {
			ghostClass: 'sortable-ghost',
			# chosenClass: "draggable",
			dragClass: 'sortable-draggable',
			animation: 300,
			easing: 'cubic-bezier(0.37, 0, 0.63, 1)',
			onEnd: do 
				let arr = []
				for item in childNodes
					arr.push item.id

				saveCompareChanges(arr)
		});
 
	def druggable id
		return id == #drugging_target

	def render
		<self[d:block]>
			for item in list
				if item[0].text
					<div.search_item id=item[0].translation>
						<div.search_res_verse_text>
							for aoefv in item
								<search-text-as-html data=aoefv innerHTML="{aoefv.text + ' '}">

						<div.search_res_verse_header [mb:0 pb:16px]>
							<svg.drag_handle xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" viewBox="0 0 24 24">
								<path d="M20,9H4v2h16V9z M4,15h16v-2H4V15z">
							<span> item[0].translation

							<svg.open_in_parallel @click.prevent.copyToClipboardFromParallel(item) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 561 561" alt=state.lang.copy>
								<title> state.lang.copy
								<path d=svg_paths.copy>


							<svg.open_in_parallel [margin: 0 8px] viewBox="0 0 400 338" @click.prevent.backInHistory({translation: item[0].translation, book: item[0].book, chapter: item[0].chapter,verse: item[0].verse}, yes)>
								<title> state.lang.open_in_parallel
								<path d=svg_paths.columnssvg style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">

							<svg.remove_parallel.close_search @click.prevent.addTranslation({short_name: item[0].translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=state.lang.delete>
								<title> state.lang.delete
								<path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
				else
					<div.search_res_verse_header id=item[0].translation [p: 16px 0px mb:0 display:flex align-items:center]>
						<svg.drag_handle [margin-right: 16px] xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" viewBox="0 0 24 24">
							<path d="M20,9H4v2h16V9z M4,15h16v-2H4V15z">

						state.lang.the_verse_is_not_available, ' ', item[0].translation, item[0].text

						<svg.remove_parallel.close_search [margin: -8px 8px 0 auto] @click.prevent.addTranslation({short_name: item[0].translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=state.lang.delete>
							<title> state.lang.delete
							<path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
