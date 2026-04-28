// Use bare specifiers so the bundler resolves these from node_modules.
import {createStore, compose, combineReducers, applyMiddleware} from 'redux';
import logger from 'redux-logger';

import currentActions from './current_actions';
import serverInfoView from './server_info';
import user from './user';
import app from './app';
import chatView from './chat_view';

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

const combinedReducers = combineReducers({app, user, currentActions, chatView, adminView: serverInfoView});

const store = createStore(combinedReducers, {}, composeEnhancers());
window.ReduxStore = store;
export {store};
