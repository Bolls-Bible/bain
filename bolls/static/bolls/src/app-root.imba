import {State} from './tags/state'
import './tags/Bible'

let Data = new State()

imba.mount <bible-reader bind=Data>

import * as smoothscroll from 'smoothscroll-polyfill'
smoothscroll.polyfill()

import {Notifications} from './tags/Notifications'
imba.mount <Notifications bind=Data>