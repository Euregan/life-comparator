import { Elm } from './Main.elm'

import salaries from '../data/salaries.json'
import inflation from '../data/inflation.json'

import './app.css'

Elm.Main.init({
  node: document.getElementById('app'),
  flags: {
    salaries: salaries,
    inflation: inflation
  }
})
