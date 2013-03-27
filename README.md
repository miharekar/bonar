#Bonar

> bónar -ja m (ọ̑) kdor ve, kje imajo bone: poglejmo na bonar / ura je bila 19 in ni vedela kje bi jedla, zato je pogledala na bonar / ostala sva brez besed in ti si rekel bonar

[Bonar: ponudniki študentske prehrane na zemljevidu](http://bonar.si/)

##About
###Scratching my own itch.

Ker mi ni bilo povšeči, da ne obstaja nobena mobilna aplikacija / mobilnikom prijazna spletna stran, ki bi prikazovala aktualno ponudbo študentske prehrane na zemljevidu, sem se odločil, da naredim svojo.

###Tech
Ko sem začenjal z izdelavo, sem se ravno odločil naučiti [Ruby on Rails](http://rubyonrails.org/). Ker nič ni boljšega, kot učenje s prakso, sem združil prijetno s koristnim ter naredil spletno aplikacijo kar z Railsi. Bonar je tako moj prvi RoR projekt, poganjata pa ga Ruby 2.0.0 in Rails 4.0.0.

###Issues
Če imate kakršnekoli probleme ali ideje glede Bonarja, kar odprite [issue](https://github.com/mrfoto/bonar/issues) ali pa me kontaktirajte na Twitterju - [@mr_foto](https://twitter.com/mr_foto).

##Thanks

* Mladen Prajdić: [@MladenPrajdic](https://twitter.com/MladenPrajdic) - for his sql expertise
* Peter Gracar: [@Pickled_Pete](https://twitter.com/Pickled_Pete) - for the name "Bonar"
* Domen Savič: [@savicdomen](https://twitter.com/savicdomen) - for countless RTs
* All other Facebook friends and Twitter followers for spreading the love

##Unofficial API

The API is in **no way** associated with official website [Študentska prehrana](http://www.studentska-prehrana.si/). It is simply one more thing I'm giving back to community.

I scrape the data from the official site every day at 04:00 GMT. The updating process takes roughly 10 minutes.

Should you use it, you absolutely must cache the response, since the data only changes once per day.

###Get restaurants

* `GET http://boni.mr.si/api/restaurants` will return all restaurants.
* `GET http://boni.mr.si/api/restaurants?search=%s` will return same response but restaurants are filtered so that name or address contain %s.

```json
[
  {
    "id": 1909,
    "name": "Dijaški in študentski dom Koper",
    "address": "Cankarjeva 5, Koper/Capodistria",
    "telephone": [],
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
    "telephone": [
      "051222152",
      "040750111"
    ],
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
    "id": 10,
    "title": "kosila"
  },
  {
    "id": 7,
    "title": "solatni bar"
  },
  {
    "id": 8,
    "title": "dostop za invalide (WC)"
  },
  {
    "id": 1,
    "title": "vegetarijanska prehrana"
  }
]
```