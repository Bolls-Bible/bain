import {State} from './views/state'
import './views/Bible'
let Data = new State()

imba.mount <bible-reader bind=Data>

import {Notifications} from './views/Notifications'
imba.mount <Notifications data=Data>