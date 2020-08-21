const fs = require('fs')
const readline = require('readline')

const metadata = {
  label: 'Logements, individus, activité, mobilités scolaires et professionnelles, migrations résidentielles en 2017',
  organism: 'INSEE',
  url: 'https://www.insee.fr/fr/statistiques/4507685?sommaire=4508161',
  date: '2017/01/01'
}

const sourceStream = fs.createReadStream('./converters/ASF_041DD16.csv', { encoding: 'utf-8' })
const outputStream = fs.createWriteStream('./converters/salaries.json')

const rl = readline.createInterface({
  input: sourceStream
})

let lineCount = 0
let data = {}

rl.on('line', (line) => {
  if (lineCount > 38 && lineCount < 72) {
    const raw = line.split('\t')

    if (!data[raw[0].split(' ')[0]]) {
      data[raw[0].split(' ')[0]] = {
        bySpc: {
          menWomen: {}
        }
      }
    }

    data[raw[0].split(' ')[0]].bySpc.menWomen.men = {
      executive: Math.round(parseInt(raw[1].replace(',', '')) / 12),
      technician: Math.round(parseInt(raw[2].replace(',', '')) / 12),
      employee: Math.round(parseInt(raw[3].replace(',', '')) / 12),
      worker: Math.round(parseInt(raw[4].replace(',', '')) / 12)
    }
  }

  if (lineCount > 72 && lineCount < 106) {
    const raw = line.split('\t')

    if (!data[raw[0].split(' ')[0]]) {
      data[raw[0].split(' ')[0]] = {
        bySpc: {
          menWomen: {}
        }
      }
    }

    data[raw[0].split(' ')[0]].bySpc.menWomen.women = {
      executive: Math.round(parseInt(raw[1].replace(',', '')) / 12),
      technician: Math.round(parseInt(raw[2].replace(',', '')) / 12),
      employee: Math.round(parseInt(raw[3].replace(',', '')) / 12),
      worker: Math.round(parseInt(raw[4].replace(',', '')) / 12)
    }
  }

  lineCount++
})

rl.on('close', () => {
  outputStream.write(JSON.stringify(data, null, 2))
})
