# README

# Implementando relaciones polimórficas en Rails



## Creación del proyecto

### Consideraciones iniciales:

**Ruby 2.6.6 / Rails 5.2.6**

### Iniciando nuevo proyecto en terminal

1. Abrir terminal
2. Crear nuevo proyecto: 
   `$ rails new Proyecto`
3. Acceder a la carpeta del proyecto
   `$ cd Proyecto`
4. Abrir el editor de código predeterminado
   `$ code .`

## Qué es el polimorfismo en Rails

En Rails, una asociación polimórfica es una asociación de Active Record que puede conectar a un modelo con múltiples modelos. Al determinar que un campo corresponde a una relación polimórifca, automáticamente rails crea dos columnas, haciendo referencia a id y type; id contiene el registro al que se hará referencia y type a la tabla a la que iremos a buscar ese registro.

## Caso práctico

En este caso queremos tener en nuestra base de datos la representación de distintos animales. Deseamos tener una tabla con el registro de las distintas especies, pero considerando que cada especie puede tener atributos distintos. Para evitar que exista una sobrecarga de campos así como registros nulos, es que utilizaremos una relación polimórfica.

Un modelo en el que generemos una tabla Animal, que se relacione con los modelos Cat, Dog y Duck quedaría del siguiente modo:

![model](https://user-images.githubusercontent.com/32393966/150847090-6a02f90d-973a-4e81-8131-51a369e02ea6.png)

En este caso, cada modelo hijo tiene un atributo propio, y todos comparten un nombre.


## Generando el modelo

Para generar los modelos correspondientes, hay que ejecutar los siguientes comandos en el terminal:

1. `$ rails g model Animal name animalable:references{polymorphic}`

Notar que se añade la columna "animalable" como una llave foránea de tipo polimórfica. La terminación -able se utiliza por convención. Es decir, si en vez de Animal el modelo que deséaramos crear fuera Image, la columna debiése llamarse "imageable".

2. `$ rails g model Cat fur`

Recordar que como fur corresponde a un string, no es necesario declararlo.

3. `$ rails g model Dog favourite_toy`

4. `$ rails g model Duck color`

5. Revisamos que las migraciones estén correctamente realizadas en nuestro editor de código, ubicadas en la carpeta db/migrate.

```ruby
class CreateAnimals < ActiveRecord::Migration[5.2]
  def change
    create_table :animals do |t|
      t.string :name
      t.references :animalable, polymorphic: true

      t.timestamps
    end
  end
end

class CreateCats < ActiveRecord::Migration[5.2]
  def change
    create_table :cats do |t|
      t.string :fur

      t.timestamps
    end
  end
end

class CreateDogs < ActiveRecord::Migration[5.2]
  def change
    create_table :dogs do |t|
      t.string :favourite_toy

      t.timestamps
    end
  end
end

class CreateDucks < ActiveRecord::Migration[5.2]
  def change
    create_table :ducks do |t|
      t.string :color

      t.timestamps
    end
  end
end
```
6. Si hay algún error de sintaxis lo podemos corregir directamente, o borrar la migración y realizarla nuevamente. Una vez esté todo correcto, corremos las migraciones con el siguiente comando:

`$ rails db:migrate`

7. Ahora podemos ver los modelos implementados en nuestro schema (db/schema.rb).

```ruby
ActiveRecord::Schema.define(version: 2022_01_24_185620) do

  create_table "animals", force: :cascade do |t|
    t.string "name"
    t.string "animalable_type"
    t.integer "animalable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["animalable_type", "animalable_id"], name: "index_animals_on_animalable_type_and_animalable_id"
  end

  create_table "cats", force: :cascade do |t|
    t.string "fur"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dogs", force: :cascade do |t|
    t.string "favourite_toy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ducks", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
```
8. Los modelos también han sido creados en la carpeta app/models

![screen_print_models](https://user-images.githubusercontent.com/32393966/150848901-628bfe8b-42da-48ca-92d2-5da1a2373a8e.png)

9. Ahora debemos acceder a los modelos. El modelo Animal se verá del siguiente modo:

    ```ruby
    class Animal < ApplicationRecord
      belongs_to :animalable, polymorphic: true
    end
    ```
10. En los modelos restantes debemos añadir la relación a la tabla Animal.
  ```ruby
  class Cat < ApplicationRecord
    has_many :animals, as: :animalable
  end

  class Dog < ApplicationRecord
    has_many :animals, as: :animalable
  end
  
  class Duck < ApplicationRecord
    has_many :animals, as: :animalable
  end
  ```
11. Listo! Ahora podemos probar que las asociaciones funcionen usando rails console.

## Probando las relaciones

Para esto, en el terminal, escribiremos el comando `$ rails c` o lo que es lo mismo, `$ rails console`

1. Comenzaremos creando registros para las tablas hijas (Cat, Dog y Duck).

`> Cat.create(fur: "brown")`

 Este comando nos devolverá un  mensaje de este tipo, indicando que el registro se ha creado correctamente.
 
 ` (0.0ms)  begin transaction
    Cat Create (0.3ms)  INSERT INTO "cats" ("fur", "created_at", "updated_at") VALUES (?, ?, ?)  [["fur", "brown"], ["created_at", "2022-01-24 19:22:17.594662"], ["updated_at", "2022-01-24 19:22:17.594662"]]
     (1151.3ms)  commit transaction
  => #<Cat id: 1, fur: "brown", created_at: "2022-01-24 19:22:17", updated_at: "2022-01-24 19:22:17">
  `
  
2. `> Dog.create(favourite_toy: "bone")`
3. `> Duck.create(color: "yellow")`
4. Ahora crearemos un animal y diremos que es un gato. Para esto, obtendremos el primer registro del modelo Cat, y lo relacionaremos con el modelo Animal.

`> Animal.create(name: "Tom", animalable: Cat.first)`

Obtendremos el siguiente mensaje:

`  Cat Load (0.4ms)  SELECT  "cats".* FROM "cats" ORDER BY "cats"."id" ASC LIMIT ?  [["LIMIT", 1]]
   (0.1ms)  begin transaction
  Animal Create (0.3ms)  INSERT INTO "animals" ("name", "animalable_type", "animalable_id", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Tom"], ["animalable_type", "Cat"], ["animalable_id", 1], ["created_at", "2022-01-24 19:27:35.588617"], ["updated_at", "2022-01-24 19:27:35.588617"]]
   (65.3ms)  commit transaction
=> #<Animal id: 1, name: "Tom", animalable_type: "Cat", animalable_id: 1, created_at: "2022-01-24 19:27:35", updated_at: "2022-01-24 19:27:35">
`

5. Crearemos nuevos registros para probar nuestro modelo:

`> Animal.create(name: "Duffy", animalable: Duck.last)
Animal.create(name: "Goofy", animalable: Dog.last)
Cat.create(fur: "black")
Animal.create(name: "Salem", animalable: Cat.last)`

6. Ahora, al obtener todos los registros de la tabla Animal, podremos ver lo siguiente:

`> Animal.all`

 `Animal Load (0.6ms)  SELECT  "animals".* FROM "animals" LIMIT ?  [["LIMIT", 11]]
=> #<ActiveRecord::Relation [#<Animal id: 1, name: "Tom", animalable_type: "Cat", animalable_id: 1, created_at: "2022-01-24 19:27:35", updated_at: "2022-01-24 19:27:35">, #<Animal id: 2, name: "Duffy", animalable_type: "Duck", animalable_id: 1, created_at: "2022-01-24 19:31:47", updated_at: "2022-01-24 19:31:47">, #<Animal id: 3, name: "Goofy", animalable_type: "Dog", animalable_id: 1, created_at: "2022-01-24 19:33:20", updated_at: "2022-01-24 19:33:20">, #<Animal id: 4, name: "Salem", animalable_type: "Cat", animalable_id: 2, created_at: "2022-01-24 19:34:03", updated_at: "2022-01-24 19:34:03">]>
`
Y podemos comprobar que cada registro en la tabla animal, aparte de tener un nombre, tiene un id que hace referencia al id en la tabla indicada en la columna animalable_type.

### Bonus:

Para hacer más legibles los resultados de las consultas en la consola, podemos utilizar la gema pry.

1. Añadir `gem pry` al gemfile.
2. Correr `$ bundle install` en el terminal.
3. Acceder a la consola de rails con `$ rails c` o, si ya estamos ahí, hacer reload!.
4. Escribir `$ pry` en la consola, lo que nos dirigirá a la consola de pry.
5. Al realizar la consulta Animal.all, obtendremos lo siguiente:

![pry](https://user-images.githubusercontent.com/32393966/150853847-167ae2a4-fa67-4b9a-8d4c-911fe1e9c8d4.png)



Fin.

***Documento creado por María Paz Carvacho.***
