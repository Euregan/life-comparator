const fs = require('fs')
const readline = require('readline')

const metada = {
  label: 'Logements, individus, activité, mobilités scolaires et professionnelles, migrations résidentielles en 2017',
  organism: 'INSEE',
  url: 'https://www.insee.fr/fr/statistiques/4507685?sommaire=4508161',
  date: '2017/01/01'
}

const region = (raw) =>
  ({
    '01': 'Guadeloupe',
    '02': 'Martinique',
    '03': 'Guyane',
    '04': 'La Réunion',
    '11': 'Île-de-France',
    '24': 'Centre-Val de Loire',
    '27': 'Bourgogne-Franche-Comté',
    '28': 'Normandie',
    '32': 'Hauts-de-France',
    '44': 'Grand Est',
    '52': 'Pays de la Loire',
    '53': 'Bretagne',
    '75': 'Nouvelle-Aquitaine',
    '76': 'Occitanie',
    '84': 'Auvergne-Rhône-Alpes',
    '93': "Provence-Alpes-Côte d'Azur",
    '94': 'Corse'
  }[raw])

const buildConstructionEndDate = (raw) =>
  ({
    '1': 'Avant 1919',
    '2': 'De 1919 à 1945',
    '3': 'De 1946 à 1970',
    '4': 'De 1971 à 1990',
    '5': 'De 1991 à 2005',
    '6': 'De 2006 à 2014',
    '7': 'Depuis 2015 (partiel)',
    Z: 'Hors logement ordinaire'
  }[raw])

const movingInYear = (raw) =>
  ({
    '1': 'Emménagement entre 1889 et 1899',
    '2': 'Emménagement entre 1900 et 1919',
    '3': 'Emménagement entre 1920 et 1939',
    '4': 'Emménagement entre 1940 et 1959',
    '5': 'Emménagement entre 1960 et 1969',
    '6': 'Emménagement entre 1970 et 1979',
    '7': 'Emménagement entre 1980 et 1989',
    '8': 'Emménagement entre 1990 et 1999',
    '9': 'Emménagement après 1999',
    Z: 'Hors logement ordinaire'
  }[raw])

const inFranceForYears = (raw) =>
  ({
    '0': 'Depuis moins de 5 ans',
    '1': 'Depuis 5 à 9 ans',
    '2': 'Depuis 10 à 19 ans',
    '3': 'Depuis 20 à 29 ans',
    '4': 'Depuis 30 à 39 ans',
    '5': 'Depuis 40 à 49 ans',
    '6': 'Depuis 50 à 59 ans',
    '7': 'Depuis 60 à 69ans',
    '8': 'Depuis 70 ans et plus',
    '9': "Non déclaré (pour un individu né à l'étranger)",
    Z: 'Individu né en France'
  }[raw])

const socioProfessionalCategory = (raw) =>
  ({
    '10': 'Agriculteurs exploitants',
    '21': 'Artisans',
    '22': 'Commerçants et assimilés',
    '23': "Chefs d'entreprise de 10 salariés ou plus",
    '31': 'Professions libérales',
    '33': 'Cadres de la fonction publique',
    '34': 'Professeurs, professions scientifiques',
    '35': "Professions de l'information, des arts et des spectacles",
    '37': "Cadres administratifs et commerciaux d'entreprise",
    '38': "Ingénieurs et cadres techniques d'entreprise",
    '42': 'Professeurs des écoles, instituteurs et assimilés',
    '43': 'Professions intermédiaires de la santé et  du travail social',
    '44': 'Clergé, religieux',
    '45': 'Professions intermédiaires administratives de la fonction publique',
    '46': 'Professions intermédiaires administratives et commerciales des entreprises',
    '47': 'Techniciens',
    '48': 'Contremaîtres, agents de maîtrise',
    '52': 'Employés civils et agents de service de la fonction publique',
    '53': 'Policiers et militaires',
    '54': "Employés administratifs d'entreprise",
    '55': 'Employés de commerce',
    '56': 'Personnels des services directs aux particuliers',
    '62': 'Ouvriers qualifiés de type industriel',
    '63': 'Ouvriers qualifiés de type artisanal',
    '64': 'Chauffeurs',
    '65': 'Ouvriers qualifiés de la manutention, du magasinage et du transport',
    '67': 'Ouvriers non qualifiés de type industriel',
    '68': 'Ouvriers non qualifiés de type artisanal',
    '69': 'Ouvriers agricoles',
    '71': 'Anciens agriculteurs exploitants',
    '72': "Anciens artisans, commerçants, chefs d'entreprise",
    '74': 'Anciens cadres',
    '75': 'Anciennes professions intermédiaires',
    '77': 'Anciens employés',
    '78': 'Anciens ouvriers',
    '81': "Chômeurs n'ayant jamais travaillé",
    '84': 'Elèves, étudiants',
    '85': 'Personnes diverses sans activité  professionnelle de moins de 60 ans (sauf retraités',
    '86': 'Personnes diverses sans activité professionnelle de 60 ans et plus (sauf retraités'
  }[raw])

const sourceStream = fs.createReadStream('./converters/FD_INDREGZC_2017.csv', { encoding: 'utf-8' })
const outputStream = fs.createWriteStream('./converters/recensement.json')

const rl = readline.createInterface({
  input: sourceStream
})

outputStream.write('[\r\n')

let lineCount = 0

rl.on('line', (line) => {
  if (lineCount > 0) {
    const raw = line.split(';')

    const data = {
      id: parseInt(raw[1]), // NUMMR
      region: region(raw[0]), // REGION
      buildConstructionEndDate: buildConstructionEndDate(raw[2]), // ACHLR
      movingInYear: movingInYear(raw[4]), // AEMMR
      yearOfBirth: parseInt(raw[9]), // ANAI
      inFranceForYears: inFranceForYears(raw[10]), // ANARR
      socioProfessionalCategory: socioProfessionalCategory(raw[28]), // CS3
      diploma: raw[32], // DIPL
      employmentContract: raw[36], // EMPL
      placeOfWork: raw[43], // ILT
      placeOfBirth: raw[46], // INAI
      nationality: raw[47], // INAT
      peopleInHousehold: raw[49], // INPER
      peopleInFamily: raw[50], // INPERF
      weight: raw[51], // IPONDI
      economicActivityCategory: raw[61], // NA88
      housingRoomCount: raw[70], // NBPI
      sex: raw[79], // SEXE
      maritalStatus: raw[82], // STAT_CONJ
      housingArea: raw[84], //SURF
      workingTime: raw[87], //TP
      workingCommuteTransport: raw[88] // TRANS
    }

    outputStream.write('  ' + JSON.stringify(data) + ',\r\n')
  }

  lineCount++

  if (lineCount > 100) {
    rl.close()
  }
})

rl.on('close', () => {
  outputStream.write(']')
})
