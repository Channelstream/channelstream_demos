// Use bare specifier so the bundler resolves redux from node_modules.
import {combineReducers} from 'redux';
import channels from './channels'
import serverStats from './server_stats';

const combinedReducers = combineReducers({serverStats, channels});
export default combinedReducers;
