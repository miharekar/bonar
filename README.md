#Študentska prehrana

[Ponudniki študentske prehrane na zemljevidu](http://boni.mr.si/)

My first Ruby on Rails app ^^

Successfully running Ruby 2.0.0 and Rails 4.0.0.

##Unofficial API
###Get restaurants

* `GET http://boni.mr.si/api/restaurants` will return all restaurants.
* `GET http://boni.mr.si/api/restaurants?search=%s` will return same response but restaurants are filtered so that name or address contain %s.

```json
[
  {
    "id": 1909,
    "name": "Dijaški in študentski dom Koper",
    "address": "Cankarjeva 5, Koper/Capodistria",
    "price": "1,37 EUR",
    "coordinates": [
      "45.54844801068044",
      "13.732124879080478"
    ],
    "opening": {
      "Week": [
        "12:00",
        "16:00"
      ],
      "Saturday": false,
      "Sunday": false,
      "Notes": "Ob petkih je lokal odprt od 12.00 do 15.00 ure."
    }
  },
  {
    "id": 1924,
    "name": "Ejga - restavracija - kavarna - pub - catering",
    "address": "Cesta maršala Tita 27, Jesenice",
    "price": "4,37 EUR",
    "coordinates": [
      "46.43674871370644",
      "14.05316910554446"
    ],
    "opening": {
      "Week": [
        "09:00",
        "20:00"
      ],
      "Saturday": [
        "09:00",
        "20:00"
      ],
      "Sunday": false
    }
  },…
]
```

###Get menu

* `GET http://boni.mr.si/api/menu?restaurant=%d` will return menu of the restaurant with id %d.

```json
[
  [
    "kostna juha",
    "Puranja pečenka,kroketi,zelenjava",
    "solatni bar 8 - solat",
    "sladica,sok"
  ],
  [
    "zelenjavna juha",
    "zelenjavna rulada,kroketi,zelenjava",
    "solatni bar 8 - solat",
    "sladica,sok"
  ],
  [
    "kostna juha",
    "hrenovka,tenstan krompir,zelenjava",
    "solatni bar 8 - solat",
    "sladica,sok"
  ],
  [
    "kostna juha",
    "pariški zrezek,tenstan krompir,zelenjava",
    "solatni bar 8 - solat",
    "sladica,sok"
  ],
  [
    "kostna juha",
    "ješprenova mineštra s klobaso",
    "solatni bar 8 - solat",
    "sladica,sok"
  ]
]
```

###Get features

* `GET http://boni.mr.si/api/features?restaurant=%d` will return features of the restaurant with id %d.

```json
[
  {
    "title": "kosila",
    "feature_id": 10
  },
  {
    "title": "solatni bar",
    "feature_id": 7
  },
  {
    "title": "dostop za invalide (WC)",
    "feature_id": 8
  },
  {
    "title": "vegetarijanska prehrana",
    "feature_id": 1
  }
]
```