import { EditorState } from '@codemirror/state'
import { EditorView, keymap, placeholder } from '@codemirror/view'
import { defaultKeymap, indentWithTab } from '@codemirror/commands'
import { history, historyKeymap } from '@codemirror/history'
import { indentOnInput } from '@codemirror/language'
import { bracketMatching } from '@codemirror/matchbrackets'
import { defaultHighlightStyle } from '@codemirror/highlight'
import { markdown, markdownLanguage, markdownKeymap } from '@codemirror/lang-markdown'
import { closeBrackets, closeBracketsKeymap } from '@codemirror/closebrackets'

import { HighlightStyle, tags } from '@codemirror/highlight'

export const syntaxHighlighting = HighlightStyle.define([
	{
		tag: tags.heading1,
		fontSize: '2em'
		fontWeight: 'bold'
		color:'var(--sky)'
	}
	{
		tag: tags.heading2
		fontSize: '1.6em'
		fontWeight: 'bold'
		color:'var(--sky)'
	}
	{
		tag: tags.heading3
		fontSize: '1.4em'
		fontWeight: 'bold'
		color:'var(--sky)'
	}
	{
		tag: tags.heading4
		fontSize: '1.2em'
		fontWeight: 'bold'
		color:'var(--sky)'
	}
	{
		tag: tags.heading5
		fontSize: '1.1em'
		fontWeight: 'bold'
		color:'var(--sky)'
	}
	{
		tag: tags.heading6
		fontWeight: 'bold'
		color:'var(--sky)'
	}
	{
		tag: [tags.processingInstruction, tags.inserted]
		opacity:0.5
	}
	{
		tag:tags.monospace
		backgroundColor:'var(--codebg)'
		color:'var(--code)'
		borderRadius:'4px'
		fontFamily:"'JetBrains Mono', monospace"
	}
	{
		tag:tags.link
		textDecoration: "underline"
		color: 'var(--indigo)'
	}
	{
		tag:tags.url
		color:'var(--blue)'
	}
	{
		tag:[tags.string, tags.special(tags.string)]
		color:'var(--lime)'
	}
	{
		tag:tags.strong
		fontWeight:'bold'
		color:'var(--rose)'
	}
	{
		tag:tags.emphasis
		color:'var(--yellow)'
		fontStyle:'italic'
	}
	{
		tag:tags.quote
		color:'var(--indigo)'
		fontStyle:'italic'
	}
	{
		tag:tags.strikethrough,
		textDecoration: "line-through"
	}

	# CODE
	{
		tag: [tags.atom, tags.bool, tags.special(tags.variableName)]
		color: 'var(--blue)'
	}
	{
		tag: [tags.keyword, tags.operator, tags.operatorKeyword]
		color: 'var(--violet)'
	}
	{
		tag: [tags.name, tags.deleted, tags.character]
		color: 'var(--orange)'
	}
	{
		tag: [tags.propertyName, tags.macroName]
		color: 'var(--rose)'
	}
	{
		tag: [tags.function(tags.variableName), tags.labelName]
		color: 'var(--sky)'
	}
	{
		tag: [tags.color, tags.constant(tags.name), tags.standard(tags.name)]
		color: 'var(--amber)'
	}
	{
		tag: [tags.definition(tags.name), tags.separator]
		color: 'var(--yellow)'
	}
	{
		tag: [tags.typeName, tags.className, tags.number, tags.changed, tags.annotation, tags.modifier, tags.self, tags.namespace]
		color: 'var(--blue)'
	}
	{
		tag: [tags.escape, tags.regexp, tags.special(tags.string)]
		color: 'var(--cyan)'
	}
	{
		tag: [tags.meta, tags.comment]
		color: 'var(--cool)'
	}
])

const bollsTheme = EditorView.theme({
	'&': {
		backgroundColor: 'transparent !important'
		fontFamily:'var(--ff)'
		font:'var(--ff)'
		height: 'auto'
		color:'var(--c)'
	}
	".cm-content": {
		caretColor: 'var(--c)'
		height:'auto'
		minHeight:"calc(72vh - 82px)"
		paddingBottom:'25%'
	}
	".cm-scroller": {
		fontFamily:'var(--ff)'
		height:'auto'
	}
	"&.cm-editor.cm-focused": {
		outline:'none'
	}
	"&.cm-focused .cm-matchingBracket, &.cm-focused .cm-nonmatchingBracket": {
		backgroundColor: "var(--acc-bgc-hover)"
		outline: "1px solid var(--acc-bgc)"
	}
}, {dark:true})


tag mark-down
	store\object
	editorView\EditorView
	lemon\String

	def setup
		editorView = new EditorView({
			state: editorState!,
			parent: self
		})

	def mount
		editorView.setState editorState!

	def editorState
		return EditorState.create({
			doc: store.note
			extensions: [
				keymap.of([...defaultKeymap, ...historyKeymap, ...closeBracketsKeymap, ...markdownKeymap, indentWithTab]),
				history(),
				closeBrackets(),
				indentOnInput(),
				bracketMatching(),
				defaultHighlightStyle.fallback,
				markdown({
					base: markdownLanguage,
					addKeymap: true,
				}),
				markdownLanguage.data.of({closeBrackets: {brackets: ["(", "[", '{', "'", '"', '`', '*', '_', '~']}}),
				placeholder(lemon + ' 🍋')
				bollsTheme,
				syntaxHighlighting,
				EditorView.lineWrapping,
				EditorView.updateListener.of(do(update)
					if update.changes
						handleChange && handleChange(update.state)
				)
			]
		})

	def handleChange e
		store.note = e.doc.toString!


	def render
		<self>

	css
		ws:pre-wrap
		height: calc(100% - 50px)
		of:auto
