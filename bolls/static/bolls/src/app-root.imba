import {State} from './tags/state'
import './tags/Bible'
# import './tags/Profile'

let Data = new State()

imba.mount <bible-reader bind=Data>

# tag app-router
# 	def render
# 		<self>
# 			<bible-reader route="/" bind=Data>
# 			<profile-page route="/profile" bind=Data>

# imba.mount <app-router>

import * as smoothscroll from 'smoothscroll-polyfill'
smoothscroll.polyfill()

import {Notifications} from './tags/Notifications'
imba.mount <Notifications bind=Data>