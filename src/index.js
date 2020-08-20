import { Elm } from './Main.elm'

import salaries from '../data/salaries.json'

import './app.css'

export default (node) =>
  Elm.Main.init({
    node: node,
    flags: {
      salaries: salaries
    }
  })
