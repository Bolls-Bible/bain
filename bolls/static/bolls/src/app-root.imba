import {State} from './tags/state'
import './tags/Bible'
let Data = new State()

imba.mount <bible-reader bind=Data>

import {Notifications} from './tags/Notifications'
imba.mount <Notifications data=Data>