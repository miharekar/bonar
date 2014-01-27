#Bonar

[![Build Status](https://travis-ci.org/mrfoto/bonar.png)](https://travis-ci.org/mrfoto/bonar)
[![Code Climate](https://codeclimate.com/github/mrfoto/bonar.png)](https://codeclimate.com/github/mrfoto/bonar)
[![Coverage Status](https://coveralls.io/repos/mrfoto/bonar/badge.png)](https://coveralls.io/r/mrfoto/bonar)
[![Dependency Status](https://gemnasium.com/mrfoto/bonar.png)](https://gemnasium.com/mrfoto/bonar)

> bónar -ja m (ọ̑) kdor ve, kje imajo bone: poglejmo na bonar / ura je bila 19 in ni vedela kje bi jedla, zato je pogledala na bonar / ostala sva brez besed in ti si rekel bonar

[Bonar: ponudniki študentske prehrane na zemljevidu](http://bonar.si/)

##About
###Scratching my own itch.

Nekega dne sem se lačen znašel v neznanem kraju. Kot pravi študent, sem najprej pomislil "le kje lahko jem na bone". Ugotovil sem, da ne obstaja niti ena mobilna aplikacija / mobilnikom prijazna spletna stran, ki bi prikazovala aktualno ponudbo študentske prehrane. Vse so ali nehali razvijati, ali pa prikazujejo netočne in/ali zastarele informacije. Zato sem se odločil, da naredim svojo.

###Tech
Ko sem začenjal z izdelavo, sem se ravno začenjal učiti [Ruby on Rails](http://rubyonrails.org/). Ker ni nič boljšega, kot učenje s prakso, sem naredil spletno aplikacijo kar z Railsi. Bonar je tako moj prvi RoR projekt in tako moj playground.

###Issues
Če imate kakršnekoli probleme, pripombe ali ideje glede Bonarja, kar odprite [issue](https://github.com/mrfoto/bonar/issues) ali pa me kontaktirajte na Twitterju - [@mr_foto](https://twitter.com/mr_foto).

##Thanks

* Boštjan Vidovič: [@bostjanvidovic](https://twitter.com/bostjanvidovic) - for the icon
* Mladen Prajdić: [@MladenPrajdic](https://twitter.com/MladenPrajdic) - for his sql expertise
* Adam Sanderson: [@adamsanderson](https://github.com/adamsanderson) - for help with Postgres arrays
* Peter Gracar: [@Pickled_Pete](https://twitter.com/Pickled_Pete) - for the name "Bonar"
* Domen Savič: [@savicdomen](https://twitter.com/savicdomen) - for countless RTs
* All other Facebook friends and Twitter followers for spreading the love

##Unofficial API

The API is in **no way** associated with official website [Študentska prehrana](http://www.studentska-prehrana.si/). It is simply one more thing I'm giving back to community as a part of [Open data.si project](http://opendata.si/).

I scrape the data from the official site every day at 05:00 GMT. The updating process takes roughly 10 minutes.

Should you use it, you absolutely must cache the response, since the data only changes once per day and the size of the response is pretty big.

###Get restaurants

* `GET http://bonar.si/api/restaurants` will return all restaurants.

```json
[
  {
    "id": 12813,
    "name": "Halo Shaolin - dostava",
    "address": "Trg OF 13, Ljubljana",
    "telephone": [
      "040549068",
      "0803808"
    ],
    "price": "4.0",
    "coordinates": [
      "46.0541149271136",
      "14.557732745077"
    ],
    "opening": {
      "week": [
        "10:00",
        "20:00"
      ],
      "saturday": [
        "11:00",
        "20:00"
      ],
      "sunday": [
        "11:00",
        "20:00"
      ],
      "notes": "27.12. od 08.00 do 18.0030.12. od 08.00 do 20.0031.12. od 08.00 do 15.00"
    },
    "menu": [
      [
        "kislo pekoča juha",
        "govedina zelenjavo",
        "mešana",
        "ocvrta banana"
      ],
      [
        "zelenjavna juha",
        "mongolska govedina",
        "mešana",
        "Ocvrti ananas"
      ],
      [
        "koruzna z rakci",
        "riž s piščancem",
        "mešana",
        "ocvrta banana"
      ]
    ],
    "features": [
      {
        "id": 2,
        "title": "celiakiji prijazni obroki"
      },
      {
        "id": 5,
        "title": "dostava"
      },
      {
        "id": 11,
        "title": "kosila"
      },
      {
        "id": 10,
        "title": "odprto ob vikendih"
      },
      {
        "id": 1,
        "title": "vegetarijanska prehrana"
      }
    ]
  },
  {
    "id": 12814,
    "name": "Hiša pod gradom",
    "address": "Streliška 10, Ljubljana",
    "telephone": [],
    "price": "3.27",
    "coordinates": [
      "46.0493199622809",
      "14.5113411755481"
    ],
    "opening": {
      "week": [
        "11:00",
        "20:00"
      ],
      "saturday": [
        "12:00",
        "20:00"
      ],
      "sunday": false
    },
    "menu": [],
    "features": [
      {
        "id": 2,
        "title": "celiakiji prijazni obroki"
      },
      {
        "id": 11,
        "title": "kosila"
      },
      {
        "id": 10,
        "title": "odprto ob vikendih"
      },
      {
        "id": 1,
        "title": "vegetarijanska prehrana"
      }
    ]
  },…
]
```
