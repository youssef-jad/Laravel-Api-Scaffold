###**Laravel API Scaffolding ( _LAS_ )**

this Library Used to Generate Laravel 5.2 APi Scaffold Module

__Requirements :__  

`1 - apt-get install libmysqlclient-dev -> Ubuntu` <br />
`2 - gem install colorize `  <br />
`3 - gem install mysql2`  <br />
`4 - gem install fileutils`  <br />
`5 - gem install yaml`  <br />


### _How To Use_ : <br />

First you Need to Configure the `config.yml`

```
    host: 'localhost'
    database: 'testDB'
    username: 'test'
    password: 'test'
```

Then Run The LAS Script 
```
ruby api-scaffold.rb 
```
You Will see list of your DB Tables 

then you will need to supply Input  <br />
``Please Type a Table Name To Make A Module For it : ``

Wait a moment and The Module will be Generated 
