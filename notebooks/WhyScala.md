# Scala: the Unpredicted Lingua Franca for Data Science

**Andy Petrella**
[noootsab@data-fellas.guru](mailto:noootsab@data-fellas.guru)<br/>
**Dean Wampler**
[dean.wampler@lightbend.com](mailto:dean.wampler@lightbend.com)

* Scala Days NYC, May 5th, 2016
* GOTO Chicago, May 24, 2016
* Strata + Hadoop World London, June 3, 2016
* Scala Days Berlin, June 16th, 2016

See also the [Spark Notebook](http://spark-notebook.io) version of this content, available at [github.com/data-fellas/scala-for-data-science](https://github.com/data-fellas/scala-for-data-science).

## Why Scala for Data Science with Spark?

While Python and R are traditional languages of choice for Data Science, [Spark](http://spark.apache.org) also supports Scala (the language in which it's written) and Java.

However, using one language for all work has advantages like simplifying the software development process, such as building, testing, and deploying techniques, coding conventions, etc.

If you want a thorough introduction to Scala, see [Dean's book](http://shop.oreilly.com/product/0636920033073.do).

So, what are the advantages, as well as disadvantages of Scala?

## 1. Functional Programming Plus Objects

Scala is a _multi-paradigm_ language. Code can look a lot like traditional Java code using _Object-Oriented Programming_ (OOP), but it also embraces _Function Programming_ (FP), which emphasizes the virtues of:

1. **Immutable values:** Mutability is a common source of bugs.
1. **Functions with no _side effects_:** All the information they need is passed in and all the "work" is returned. No external state is modified.
1. **Referential transparency:** You can replace a function call with a cached value that was returned from a previous invocation with the same arguments. (This is a benefit enabled by functions without side effects.)
1. **Higher-order functions:** Functions that take other functions as arguments are return functions as results.
1. **Structure separated from operations:** A core set of collections meets most needs. An operation applicable to one data structure is applicable to all.

However, objects are still useful as an _encapsulation_ mechanism. This is valuable for projects with large teams and code bases. 
Scala also implements some _functional_ features using _object-oriented inheritance_ (e.g., "abstract data types" and "type classes", for you experts...).

### What about the other languages? 
* **Python:** Supports mixed FP-OOP programming, too, but isn't as "rigorous". 
* **R:** As a Statistics language, R is more functional than object-oriented.
* **Java:** An object-oriented language, but with recently introduced functional constructs, _lambdas_ (anonymous functions) and collection operations that follow a more _functional_ style, rather than _imperative_ (i.e., where mutating the collection is embraced).

There are a few differences with Java's vs. Scala's approaches to OOP and FP that are worth mentioning specifically:

### 1a. Traits vs. Interfaces
Scala's object model adds a _trait_ feature, which is a more powerful concept than Java 8 interfaces. Before Java 8, there was no [mixin composition](https://en.wikipedia.org/wiki/Mixin) capability in Java, where composition is generally [preferred over inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance). 

Imagine that you want to define reusable logging code and mix it into other classes declaratively. Before Java 8, you could define the abstraction for logging in an interface, but you had to use some ad hoc mechanism to implement it (like implementing all methods to delegate to a helper object). Java 8 added the ability to provide default method definitions, as well as declarations in interfaces. This makes mixin composition easier, but you still can't add fields (for state), so the capability is limited. 

Scala traits fully support mixin composition by supporting both field and method definitions with flexibility rules for overriding behavior, once the traits are mixed into classes.

### 1b. Java Streams
When you use the Java 8 collections, you can convert the traditional collections to a "stream", which is lazy and gives you more functional operations. However, sometimes, the conversions back and forth can be tedious, e.g., converting to a stream for functional processing, then converting pass them to older APIs, etc. Scala collections are more consistently functional.

### The Virtue of Functional Collections: 
Let's examine how concisely we can operate on a collection of values in Scala and Spark.

First, let's define a helper function: is an integer a prime? (Naïve algorithm from [Wikipedia](https://en.wikipedia.org/wiki/Primality_test).)

```scala
def isPrime(n: Int): Boolean = {
  def test(i: Int, n2: Int): Boolean = {
    if (i*i > n2) true
    else if (n2 % i == 0 || n2 % (i + 2) == 0) false
    else test(i+6, n2)
  }
  if (n <= 1) false
  else if (n <= 3) true
  else if (n % 2 == 0 || n % 3 == 0) false
  else test(5, n)
}
```

Note that no values are mutated here ("virtue" #1 listed above) and `isPrime` has no side effects (#2), which means we could cache previous invocations for a given `n` for better performance if we called this a lot (#3)!

### Scala Collections Example
Let's compare a Scala collections calculation vs. the same thing in Spark; how many prime numbers are there between 1 and 100, inclusive?

```scala
(1 to 100).                    // Range of integers from 1 to 100, inclusive.
  map(i => (i, isPrime(i))).   // `map` is a higher-order method; we pass it
                               // a function (#4)
  groupBy(tuple => tuple._2).  // ... and so is `groupBy`, etc.
  map(tuple => (tuple._1, tuple._2.size))
```

This produces the results:
```scala
res16: scala.collection.immutable.Map[Boolean,Int] = Map(
    false -> 75, true -> 25)
```
Note that for the numbers between 1 and 100, inclusive, exactly 1/3 of them are prime!

### Spark Example

Note how similar the following code is to the previous example. After constructing the data set, the "core" three lines are _identical_, even though they are operating on completely different underlying collections (#5 above). 

However, because Spark collections are "lazy" by default (i.e., not evaluated until we ask for results), we explicitly print the results so Spark evaluates them!

```scala
val rddPrimes = sparkContext.parallelize(1 to 100).
  map(i => (i, isPrime(i))).
  groupBy(tuple => tuple._2).
  map(tuple => (tuple._1, tuple._2.size))
rddPrimes.collect
```

This produces the result:
```scala
rddPrimes: org.apache.spark.rdd.RDD[(Boolean, Int)] = 
  MapPartitionsRDD[4] at map at <console>:61
res18: Array[(Boolean, Int)] = Array((false,75), (true,25))
```

Note the inferred type, an `RDD` with records of type `(Boolean, Int)`, meaning two-element tuples.

Spark's RDD API is inspired by the Scala collections API, which is inspired by classic _functional programming_ operations on data collections, i.e., using a series of transformations from one form to the next, without mutating any of the collections. (Spark is very efficient about avoiding the materialization of intermediate outputs.)

Once you know these operations, it's quick and effective to implement robust, non-trivial transformations.

What about the other languages? 

* **Python:** Supports very similar functional programming. In fact, Spark Python code looks very similar to Spark Scala code. 
* **R:** More idiomatic (see below).
* **Java:** Looks similar when _lambdas_ are used, but missing features (see below) limit concision and flexibility.

## 2. Interpreter (REPL)

In the notebook, we've been using the Scala interpreter (a.k.a., the REPL - Read Eval, Print, Loop) already behind the scenes. It makes notebooks like this one possible!

What about the other languages? 

* **Python:** Also has an interpreter and [iPython/Jupyter](https://ipython.org/) was one of the first, widely-used notebook environments.
* **R:** Also has an interpreter and notebook/IDE environments.
* **Java:** Does _not_ have an interpreter and can't be programmed in a notebook environment. However, Java 9 will have a REPL, after 20+ years!

## 3. Tuple Syntax
In data, you work with records of `n` fields (for some value of `n`) all the time. Support for `n`-element _tuples_ is very convenient and Scala has a shorthand syntax for instantiating tuples. We used it twice previously to return two-element tuples in the anonymous functions passed to the `map` methods above:

```scala
sparkContext.parallelize(1 to 100).
  map(i => (i, isPrime(i))).                // <-- here
  groupBy(tuple => tuple._2).
  map(tuple => (tuple._1, tuple._2.size))   // <-- here
```

As before, REPL prints the following:

```scala
res20: org.apache.spark.rdd.RDD[(Boolean, Int)] = 
  MapPartitionsRDD[9] at map at <console>:63
```

**Tuples are used all the time** in Spark Scala RDD code, where it's common to use key-value pairs.

What about the other languages? 

* **Python:** Also has some support for the same tuple syntax.
* **R:** Also has tuple types, but a less convenient syntax for instantiating them.
* **Java:** Does _not_ have tuple types, not even the special case of two-element tuples (pairs), much less a convenient syntax for them. However, Spark defines a [MutablePair](http://spark.apache.org/docs/latest/api/java/org/apache/spark/util/MutablePair.html) type for this purpose:

```scala
// Using Scala syntax here:
import org.apache.spark.util.MutablePair
val pair = new MutablePair[Int,String](1, "one")
```

The REPL prints:
```scala
import org.apache.spark.util.MutablePair
pair: org.apache.spark.util.MutablePair[Int,String] = (1,one)
```

## 4. Pattern Matching
This is one of the most powerful features you'll find in most functional languages, Scala included. It has no equivalent in Python, R, or Java.

Let's rewrite our previous primes example:

```scala
sparkContext.parallelize(1 to 100).
  map(i => (i, isPrime(i))).
  groupBy{ case (_, primality) => primality}.  // Syntax: { case pattern => body }
  map{ case (primality, values) => (primality, values.size) } . // same here
  foreach(println)
```

The output is:
```scala
(true,25)
(false,75)
```

Note the `case` keyword and `=>` separating the pattern from the body to execute if the pattern matches.

In the first pattern, `(_, primality)`, we didn't need the first tuple element, so we used the "don't care" placeholder, `_`. Note also that `{...}` must be used instead of `(...)`. (The extra whitespace after the `{` and before the `}` is not required; it's here for legibility.)

Pattern matching is much richer, while more concise than `if ... else ...` constructs in the other languages and we can use it on nearly anything to match what it is and then decompose it into its constituent parts, which are assigned to variables with meaningful names, e.g., `primality`, `values`, etc. 

Here's another example, where we _deconstruct_ a nested tuple. We also show that you can use pattern matching for assignment, too!

```scala
val (a, (b1, (b21, b22)), c) = ("A", ("B1", ("B21", "B22")), "C")
```

Note the output of the REPL:
```scala
a: String = A
b1: String = B1
b21: String = B21
b22: String = B22
c: String = C
```

## 5. Case Classes 
Now is a good time to introduce a convenient way to declare classes that encapsulate some state that is composed of some values, called _case classes_.

```scala
case class Person(firstName: String, lastName: String, age: Int)
```

The `case` keyword tells the compiler to:

* Make immutable instance fields out of the constructor arguments (the list after the name).
* Add `equals`, `hashCode`, and `toString` methods (which you can explicitly define yourself, if you want).
* Add a _companion object_ with the same name, which holds methods for constructing instances and "destructuring" instances through patterning matching.
* etc.

Case classes are useful for implementing records in RDDs.

Let's see case class pattern matching in action:

```scala
sparkContext.parallelize(
    Seq(Person("Dean", "Wampler", 39), 
    Person("Andy", "Petrella", 29))).
  map { 
    // Convert Person instances to tuples
    case Person(first, last, age) => (first, last, age)  
  }.
  foreach(println)
```

Output:
```scala
(Andy,Petrella,29)
(Dean,Wampler,39)
```

What about the other languages? 

* **Python:** Regular expression matching for strings is built in. Pattern matching as shown requires a third-party library with an idiomatic syntax. Nothing like case classes.
* **R:** Only supports regular expression matching for strings. Nothing like case classes.
* **Java:** Only supports regular expression matching for strings. Nothing like case classes.

## 6. Type Inference
Most languages associate a type with values, but they fall into two categories, crudely speaking, those which evaluate the type of expressions and variables at compile time (like Scala and Java) and those which do so at runtime (Python and R). This is call _static typing_ and _dynamic typing_, respectively.

So, languages with static typing either have to be told the type of every expression or variable, or they can _infer_ types in some or all cases. Scala can infer types most of the time, while Java can do so only in limited cases. Here are some examples for Scala. Note the results shown for each expression:

```scala
val i = 100       // <- infer that i is an integer
val j = i*i % 27  // <- since i is an integer, j must be one, too.
```

The compiler infers the following:
```scala
i: Int = 100
j: Int = 10
```

Recall our previous Spark example, where we wrote nothing about types, but they were inferred: 

```scala
sparkContext.parallelize(1 to 100).
  map(i => (i, isPrime(i))).
  groupBy{ case(_, primality) => primality }.
  map{ case (primality, values) => (primality, values.size) }
```

Output:
```scala
res30: org.apache.spark.rdd.RDD[(Boolean, Int)] = 
    MapPartitionsRDD[21] at map at <console>:66
```

So this long expression (and it is a four-line expression - note the "."'s) returns an `RDD[(Boolean, Int)]`. Note that we can also express a tuple _type_ with the `(...)` syntax, just like for tuple _instances_. This type could also be written `RDD[Tuple2[Boolean, Int]]`.

Put another way, we have an `RDD` where the records are key-value pairs of `Booleans` and `Ints`.

I really like the extra safety that static typing provides, without the hassle of writing the types for almost everything, compared to Java. Furthermore, when I'm using an API with the Scala interpreter or a notebook like this one, the return value's type is shown, as in the previous example, so I know exactly what "kinds of things" I have. That also means I don't have to know _in advance_ what a method will return, in order to explicit add a required type, as in Java.

What about the other languages? 

* **Python:** Uses dynamic typing, so no types are written explicitly, but you also don't get the feedback type inference provides, as in our `RDD[(Boolean, Int)]` example.
* **R:** Also dynamically typed.
* **Java:** Statically typed with explicit types required almost everywhere.

## 7. Unification of Primitives and Types
In Java, there is a clear distinction between primitives, which are nice for performance (you can put them in registers, you can pass them on the stack, you don't heap allocate them), and instances of classes, which give you the expressiveness of OOP, but with the overhead of heap allocation, etc.

Scala unifies the syntax, but in most cases, compiles optimal code. So, for example, `Float` acts like any other type, e.g., `String`, with methods you call, but the compiler uses JVM `float` primitives. `Float` and the other primitives are subtypes of `AnyVal` and include `Byte`, `Short`, `Int`, `Long`, `Float`, `Double`, `Char`, `Boolean`, and `Unit`.

Another benefit is that the uniformity extends to parameterized types, like collections. If you implement your own `Tree[T]` type, `T` can be `Float`, `String`, `MyMassiveClass`, whatever. There's no mental burden of explicitly boxing and unboxing primitives.

However, the downside is that your primitives will be boxed when used in a context like this. Scala does have an annotation `@specialized(a,b,c)` that's used to tell the compiler to generate optimal implementations for the primitives listed for `a,b,c`, but it's not a perfect solution.

```scala
val listString: List[String] = List("one", "two", "three")
val listInt:    List[Int]    = List(1, 2, 3)    // No need to use Integer.
```

Output:
```scala
listString: List[String] = List(one, two, three)
listInt: List[Int] = List(1, 2, 3)
```

See also **Value Classes** below.

## 8. Elegant Tools to Create "Domain Specific Languages"
The Spark [DataFrame](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.DataFrame) API is a good example of DSL that mimics the original Python and R DataFrame APIs for single-node use. 

First, set up the API:
```scala
import org.apache.spark.sql.SQLContext
val sqlContext = new SQLContext(sparkContext)
import sqlContext.implicits._ 
import org.apache.spark.sql.functions._  // for min, max, etc. column operations
```

Get the root directory of the notebooks:
```scala
val root = sys.env("NOTEBOOKS_DIR")
```

Load the airports data into a [DataFrame](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.DataFrame).

```scala
val airportsDF = sqlContext.read.json(s"$root/airports.json")
```

Note the "schema" is inferred from the JSON and shown by the REPL (by calling `DataFrame.toString`).

```scala
airportsDF: org.apache.spark.sql.DataFrame = [airport: string, city: string, country: string, iata: string, lat: double, long: double, state: string]
```

We cache the results, so Spark will keep the data in memory since we'll run a few queries over it. `DataFrame.show` is convenient for displaying the first `N` records (20 by default).

```scala
airportsDF.cache
airportsDF.show
```

Here's the output of `show`:
```
+--------------------+------------------+-------+----+-----------+------------+-----+
|             airport|              city|country|iata|        lat|        long|state|
+--------------------+------------------+-------+----+-----------+------------+-----+
|            Thigpen |       Bay Springs|    USA| 00M|31.95376472|-89.23450472|   MS|
|Livingston Municipal|        Livingston|    USA| 00R|30.68586111|-95.01792778|   TX|
|         Meadow Lake|  Colorado Springs|    USA| 00V|38.94574889|-104.5698933|   CO|
|        Perry-Warsaw|             Perry|    USA| 01G|42.74134667|-78.05208056|   NY|
|    Hilliard Airpark|          Hilliard|    USA| 01J| 30.6880125|-81.90594389|   FL|
|   Tishomingo County|           Belmont|    USA| 01M|34.49166667|-88.20111111|   MS|
|         Gragg-Wade |           Clanton|    USA| 02A|32.85048667|-86.61145333|   AL|
|             Capitol|        Brookfield|    USA| 02C|   43.08751|-88.17786917|   WI|
|   Columbiana County|    East Liverpool|    USA| 02G|40.67331278|-80.64140639|   OH|
|    Memphis Memorial|           Memphis|    USA| 03D|40.44725889|-92.22696056|   MO|
|      Calhoun County|         Pittsboro|    USA| 04M|33.93011222|-89.34285194|   MS|
|    Hawley Municipal|            Hawley|    USA| 04Y|46.88384889|-96.35089861|   MN|
|Griffith-Merrillv...|          Griffith|    USA| 05C|41.51961917|-87.40109333|   IN|
|Gatesville - City...|        Gatesville|    USA| 05F|31.42127556|-97.79696778|   TX|
|              Eureka|            Eureka|    USA| 05U|39.60416667|-116.0050597|   NV|
|    Moton  Municipal|          Tuskegee|    USA| 06A|32.46047167|-85.68003611|   AL|
|          Schaumburg|Chicago/Schaumburg|    USA| 06C|41.98934083|-88.10124278|   IL|
|     Rolla Municipal|             Rolla|    USA| 06D|48.88434111|-99.62087694|   ND|
|    Eupora Municipal|            Eupora|    USA| 06M|33.53456583|-89.31256917|   MS|
|            Randall |        Middletown|    USA| 06N|41.43156583|-74.39191722|   NY|
+--------------------+------------------+-------+----+-----------+------------+-----+
only showing top 20 rows
```

Now we can show the idiomatic DataFrame API (DSL) in action:

```scala
val grouped = airportsDF.groupBy($"state", $"country").count.orderBy($"count".desc)
grouped.printSchema
grouped.show(100)  // 50 states + territories < 100
```

Here is the output:

```
root
 |-- state: string (nullable = true)
 |-- country: string (nullable = true)
 |-- count: long (nullable = false)

+-----+-------+-----+
|state|country|count|
+-----+-------+-----+
|   AK|    USA|  263|
|   TX|    USA|  209|
|   CA|    USA|  205|
|   OK|    USA|  102|
|   FL|    USA|  100|
|   OH|    USA|  100|
|   NY|    USA|   97|
|   GA|    USA|   97|
|   MI|    USA|   94|
|   MN|    USA|   89|
|   IL|    USA|   88|
|   WI|    USA|   84|
|   KS|    USA|   78|
|   IA|    USA|   78|
|   AR|    USA|   74|
|   MO|    USA|   74|
|   NE|    USA|   73|
|   AL|    USA|   73|
|   MS|    USA|   72|
|   NC|    USA|   72|
|   PA|    USA|   71|
|   MT|    USA|   71|
|   TN|    USA|   70|
|   WA|    USA|   65|
|   IN|    USA|   65|
|   AZ|    USA|   59|
|   SD|    USA|   57|
|   OR|    USA|   57|
|   LA|    USA|   55|
|   ND|    USA|   52|
|   SC|    USA|   52|
|   NM|    USA|   51|
|   KY|    USA|   50|
|   CO|    USA|   49|
|   VA|    USA|   47|
|   ID|    USA|   37|
|   UT|    USA|   35|
|   NJ|    USA|   35|
|   ME|    USA|   34|
|   WY|    USA|   32|
|   NV|    USA|   32|
|   MA|    USA|   30|
|   WV|    USA|   24|
|   MD|    USA|   18|
|   HI|    USA|   16|
|   CT|    USA|   15|
|   NH|    USA|   14|
|   VT|    USA|   13|
|   PR|    USA|   11|
|   RI|    USA|    6|
|   DE|    USA|    5|
|   VI|    USA|    5|
|   CQ|    USA|    4|
|   AS|    USA|    3|
|   GU|    USA|    1|
|   DC|    USA|    1|
+-----+-------+-----+

grouped: org.apache.spark.sql.DataFrame = [state: string, country: string, count: bigint]
```

By the way, this DSL is essentially a programmatic version of SQL:

```scala
airportsDF.registerTempTable("airports")
val grouped2 = sqlContext.sql("""
  SELECT state, country, COUNT(*) AS cnt FROM airports
  GROUP BY state, country
  ORDER BY cnt DESC
""")
```

What about the other languages? 

* **Python:** Dynamically-typed languages often have features that make idiomatic DSLs easy to define. The Spark DataFrame API is inspired by the [Pandas DataFrame](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.html) API.
* **R:** Less flexible for idiomatic DSLs, but syntax is designed for Mathematics. The Pandas DataFrame API is inspired by the [R Data Frame](http://www.r-tutor.com/r-introduction/data-frame) API.
* **Java:** Limited to so-called _fluent_ APIs, similar to our collections and RDD examples above.

## 9. And a Few Other Things...
There are many more Scala features that the other languages don't have or don't support as nicely. Some are actually quite significant for general programming tasks, but they are used less frequently in Spark code. Here they are, for completeness.

### 9A. Singletons Are a Built-in Feature
Implement the _Singleton Design Pattern_ without special logic to ensure there's only one instance.

```scala
object Foo {
  def main(args: Array[String]):Unit = {
    args.foreach(arg => println(s"arg = $arg"))
  }
}
Foo.main(Array("Scala", "is", "great!"))
```

The output is:
```
arg = Scala
arg = is
arg = great!
defined object Foo
```

### 9B. Named and Default Arguments
Does a method have a long argument list? Provide defaults for some of them. Name the arguments when calling the method to document what you're doing.

```scala
val airportsRDD = grouped.select($"count", $"state").
  map(row => (row.getLong(0), row.getString(1)))

val rdd1 = airportsRDD.sortByKey() // defaults: ascending = true, numPartitions = current # of partitions
val rdd2 = airportsRDD.sortByKey(ascending = false) // name the ascending argument explicitly
val rdd3 = airportsRDD.sortByKey(numPartitions = 4) // name the numPartitions argument explicitly
val rdd4 = airportsRDD.sortByKey(ascending = false, numPartitions = 4) // Okay to do both...
```

All four variants return the same type:
```scala
rdd1: org.apache.spark.rdd.RDD[(Long, String)] = ShuffledRDD[60] at sortByKey at <console>:74
rdd2: org.apache.spark.rdd.RDD[(Long, String)] = ShuffledRDD[63] at sortByKey at <console>:75
rdd3: org.apache.spark.rdd.RDD[(Long, String)] = ShuffledRDD[66] at sortByKey at <console>:76
rdd4: org.apache.spark.rdd.RDD[(Long, String)] = ShuffledRDD[69] at sortByKey at <console>:77
```

To see the impacts of the arguments:
```scala
Seq(rdd1, rdd2, rdd3, rdd4).foreach { rdd => 
  println(s"RDD (#partitions = ${rdd.partitions.length}):")
  rdd.take(10).foreach(println)
}
```

Output:
```
RDD (#partitions = 41):
(1,GU)
(1,DC)
(3,AS)
(4,CQ)
(5,VI)
(5,DE)
(6,RI)
(11,PR)
(13,VT)
(14,NH)
RDD (#partitions = 41):
(263,AK)
(209,TX)
(205,CA)
(102,OK)
(100,OH)
(100,FL)
(97,NY)
(97,GA)
(94,MI)
(89,MN)
RDD (#partitions = 4):
(1,GU)
(1,DC)
(3,AS)
(4,CQ)
(5,VI)
(5,DE)
(6,RI)
(11,PR)
(13,VT)
(14,NH)
RDD (#partitions = 4):
(263,AK)
(209,TX)
(205,CA)
(102,OK)
(100,OH)
(100,FL)
(97,NY)
(97,GA)
(94,MI)
(89,MN)
```

### 9C. String Interpolation
You've seen it used already:

```scala
println(s"RDD #partitions = ${rdd4.partitions.length}")
// prints: RDD #partitions = 4
```

### 9D. Few Semicolons
Semicolons are inferred, making your code just that much more concise. You can use them if you want to write more than one expression on a line:

```scala
val result = "foo" match {
  case "foo" => println("Found foo!"); true
  case _ => false
}
// prints: Found foo!
```

### 9E. Tail Recursion Optimization
Recursion isn't used much in user code for Spark, but for general programming it's a powerful technique. Unfortunately, most OO languages (like Java) do not optimize [tail call recursion](https://en.wikipedia.org/wiki/Tail_call) by converting the recursion into a loop. Without this optimization, use of recursion is risky, because of the risk of stack overflow. Scala's compiler implements this optimization.

```scala
def printSeq[T](seq: Seq[T]): Unit = seq match {
  case head +: tail => println(head); printSeq(tail)
  case Nil => // done
}
printSeq(Seq(1,2,3,4))
// prints:
// 1
// 2
// 3
// 4
```

### 9F. Everything Is an Expression
Some constructs are _statements_ (meaning they return nothing) in some languages, like `if ... then ... else`, `for` loops, etc. Almost everything is an expression in Scala which means you can assign results of the `if` or `for` expression. The alternative in the other languages is that you have to declare a mutable variable, then set its value inside the statement.

```scala
val worldRocked = if (true == false) "yes!" else "no"
```

As you might expect, the output is:
```
worldRocked: String = no
```

```scala
val primes = for {
  i <- 0 until 100
  if isPrime(i)
} yield i
```

The output is:
```scala
primes: scala.collection.immutable.IndexedSeq[Int] = 
  Vector(2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 
         41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97)
```

### 9G. Implicits
One of Scala's most powerful features is the _implicits_ mechanism. It's used (or misused) for several capabilities, but one of the most useful is the ability to "add" methods to existing types that don't already have the methods. What actually happens is the compiler invokes an _implicit conversion_ from an instance of the type to a wrapper type that has the desired method. 

For example, suppose I want to add a `toJSON` method to my `Person` type above, but I don't want this added to the class itself. Maybe it's from a library that I can't modify. Maybe I only want this method in some contexts, but I don't want its baggage everywhere. Here's how to do it.

```scala
// repeat definition of Person: 
case class Person(firstName: String, lastName: String, age: Int)

implicit class PersonToJSON(person: Person) {
  // Just return a JSON-formatted string, for simplicity of the example:
  def toJSON: String = 
    s"""{ "firstName": ${person.firstName}, "lastName": ${person.lastName}, "age": ${person.age} }"""
}

val p = Person("Dean", "Wampler", 39)
p.toJSON   // Like magic!!
// returns: { "firstName": Dean, "lastName": Wampler, "age": 39 }
```

The `implicit` keyword tells the compiler to consider `PersonToJSON` when I attempt to call `toJSON` on a `Person` instance. The compiler finds this implicit class and does the conversion implicitly, then calls the `toJSON` method.

There are many other uses for implicits. They are a powerful implementation tool for various design problems, but they have to be used wisely, because it can be difficult for the reader to know what's going on.

### 9H. Sealed Type Hierarchies
An important concept in modern languages is _sum types_, where there is a finite set of possible instances. Two examples from Scala are `Option[T]` and its allowed subtypes `Some[T]` and `None`, and `Either[L,R]` and its subtypes `Left[L]` and `Right`[R]`.

Note that `Option[T]` represents two and only two possible states, either I have something, a `T` inside a `Some[T]`, or I don't anything, a `None`. There are no additional "states" that are logically possible for the `Option[T]` "abstraction". Similarly, `Either[L,R]` encapsulates a similar dichotomy, often used for "failure" (e.g., `Left[Throwable]` by convention) and "successful result" (`Right[T]` for some "expected" `T`).

The term _sum type_ comes from an analog between types and arithmetic. For `Option`, the number of allowed intances (ignoring the type parameter `T`) is just the sum, _two_. Similarly for `Either`.

There are also _product types_, like tuples, where you can combining types together _multiples_ the number of instances. For example, a tuple of `(Option,Either)` would have 2*2 instances. A tuple `(Boolean,Option,HTTP_Commands)` has 2*2*7 possible instances (there are 7 HTTP 1.1 commands, like `GET`, `POST`, etc.)

Scala use type hierarchies for sum types, where an abstract _sealed_ trait or class is used for the base type, e.g., `Option[T]` and `Either[L,R]`, and subtypes represent the concrete types. The `sealed` keyword is used on the base type and it is crucial; it tells the compiler to only allow subtypes to be defined in the same _file_, which means users can't add their own subtypes, breaking the logic of the type.

Some other languages implement sumtypes using a variation of _enumerations_. Jave has that, but it's a much more limited concept than true subtypes.

Here's an example, sort of like `Either`, but oriented more towards the usage of encapsulating success or failure. However, we'll put "success" on the left instead of the right, which is the convention when using `Either`.

We'll have one type parameter `Result`. On `Success`, it will hold an instance of the type `Result`. On Failure, it will hold no successful result, so we'll use the "bottom" type `Nothing` for the type parameter,
and expect the error information to be returned in a `RuntimeException`.

```scala
import scala.util.control.NonFatal

// The + means "contravariant"; we can use subtypes of the declared "Result". 
// See also the **Definition Site Invariance...** section below.
sealed trait SuccessOrFailure[+Result]  
case class   Success[Result](result: Result)  extends SuccessOrFailure[Result]
case class   Failure(error: RuntimeException) extends SuccessOrFailure[Nothing]
```

The `sealed` keyword is actually less useful in the context of this notebook; we can keep on defining subclasses below. However, in library code, you would put the three declarations in a separate file and then the compiler would prevent anyone from defining a third subclass in a different location.

Let's try it out.

```scala
def parseInt(string: String): SuccessOrFailure[Int] = try {
  Success(Integer.parseInt(string))
} catch {
  case nfe: NumberFormatException => Failure(new RuntimeException(s"""Invalid integer string: "$string" """))
}

Seq("1", "202", "three").map(parseInt)
// Seq[SuccessOrFailure[Int]] = List(
//   Success(1), 
//   Success(202), 
//   Failure(java.lang.RuntimeException: Invalid integer string: "three" ))
```

### 9I. Option Type Broken in Java
Speaking of `Option[T]`, Java 8 introduced a similar type called `Optional`. (The name `Option` was already used for something else.) However, its design has some subtleties that make the behavior not straightforward when `nulls` are involved. For details, see [this blog post](https://developer.atlassian.com/blog/2015/08/optional-broken/).

### 9J: Definition-site Variance vs. Call-site Variance
This is a technical point. In Java, when you define a type with a type parameter, like our `SuccessOrFailure[T]` previously, to hold items of some type `T`, you can't specify in the declaration whether it's okay to substitute a subtype of `SuccessOrFailure` with a subtype of `T`. For example, is the following okay?:

```java
// Java
SuccessOrFailure<Object> sof = null;
...
sof = new Success<String>("foo");
```

This substitutability is called _variance_, referring to the variance allowed in `T` if we use a subtype of the outer type, `SuccessOrFailure`. Notice that we want to assign a subclass of `SuccessOrFailure` _and_ a subtype of `Object`. In this case, we're doing _covariant substitution_, because the subtyping "moves in the same direction", from parent to child for both types. There's also _contravariant_, where the type parameter moves "up" while the outer type moves "down", and _invariant_ typing, where you can't change the type parameter. That is, in the invariant case, we could only assign `Success<Object>(...)` to `sof`.

Java does not let the type _designer_ specify the correct behavior. This means Java forces the _user_ of the type to specify the variance at the _call site_:

```java
SuccessOrFailure<? extends Object> sof = null;
...
sof = new Success<String>("foo");

```

This is harder for the user, who has to understand what's okay in this case, both what the designer intended and some technical rules of type theory. 

It's much better if the _designer_ of `SuccessOrFailure[T]`, who understands the desired behavior, defines the allowed variance behavior at the _definition site_, which Scala supports. Recall from above:

```scala
// Scala
sealed trait SuccessOrFailure[+Result]  
case class   Success[Result](result: Result)  extends SuccessOrFailure[Result]
case class   Failure(error: RuntimeException) extends SuccessOrFailure[Nothing]

...
// usage:
val sof: SuccessOrFailure[AnyRef] = new Success[String]("Yea!")
```

### 9K: Value Classes
Scala's built-in _value types_ `Int`, `Long`, `Float`, `Double`, `Boolean`, and `Unit` are implemented with the corresponding JVM primitive values, eliminating the overhead of allocating an instance on the heap. What if you define a class that wraps _one_ of these values?
```scala
class Celsius(value: Float) {
  // methods
}
```
  
Unfortunately, instances are allocated on the heap, even though all instance "state" is held by a single primitive `Float`. Scala now has an `AnyVal` trait. If you use it as a parent of types like `Celsius`, they will enjoy the same optimization that the built-in value types enjoy. That is, the single primitive field (`value` here) will be pushed on the stack, etc., and no instance of `Celsius` will be heap allocated, _in most cases._

```scala
class Celsius(value: Float) extends AnyVal {
  // methods
}
```

So, why doesn't Scala make this optimization automatically? There are some limitations, which are described [here](http://docs.scala-lang.org/overviews/core/value-classes.html) and in [my book](http://shop.oreilly.com/product/0636920033073.do).

### 9L. Lazy Vals
Sometimes you don't want to initialize a value if doing so is expensive and you won't always need it. Or, sometimes you just want to delay the "hit" so you're up and running more quickly. For example, a database connection is expensive.

```scala
lazy val jdbcConnection = new JDBCConnection(...)
```

Use the `lazy` keyword to delay initialization until it's actually needed (if ever). This feature can also be used to solve some tricky "order of initialization" problems. It has one drawback; there will be extra overhead for every access to check if it has already been initialized, so don't do this if the value will be read a lot. A future version of Scala will remove this overhead.

What about the other languages? 

* **Python:** Offers equivalents for some these features.
* **R:** Supports some of these features.
* **Java:** Supports none of these features.

# But Scala Has Some Disadvantages...

All of the advantages discussed above make Scala code quite concise, especially compared to Java code. There are lots of nifty features available to solve particular design problems.

However, no language is perfect. You should know about the disadvantages of Scala, too.

Here, I'll briefly summarize some Scala and JVM issues, especially for Spark, but Dean's talk at [Strata San Jose](http://conferences.oreilly.com/strata/hadoop-big-data-ca/public/schedule/detail/47105) ([extended slides](http://deanwampler.github.io/polyglotprogramming/papers/ScalaJVMBigData-SparkLessons-extended.pdf)) goes into more details.

## 1. Data-centric Tools and Libraries

The R and Python communities have a much wider selection of data-centric tools and libraries. Python is great for general data science. R was developed by statisticians, so it has a very rich library of statistical algorithms and rich options for charting, like [ggplot2](http://ggplot2.org/).

## 2. The JVM Has Some Issues

Big Data has pushed the limits of the JVM in interesting ways.

### 2a. Integer indexing of arrays

Because Java has _signed_ integers only and because arrays are indexed by integers instead of longs, array sizes are limited to 2 billion elements. Therefore, _byte_ arrays, which are often used for holding serialized data, are limited to 2GB. This is in an era when _terabyte_ heaps (TB) are becoming viable!

There's no real workaround when you want the efficiency of arrays, except to implement logic that can split a large object into "chunks" and manage them accordingly.

### 2b. Inefficiency of the JVM Memory Model
The JVM has a very flexible, general-purpose model of organizing data into memory and managing garbage collection. However, for massive data sets of records with the same or nearly the same schema, the model is very inefficient. Spark's [Tungsten Project](https://databricks.com/blog/2015/04/28/project-tungsten-bringing-spark-closer-to-bare-metal.html) is addressing this problem by introducing custom object-layouts, managed memory, as well as code generation for other performance bottlenecks.

Here is an example of how Java typically lays out objects in memory. Note the references to small, discontiguous chunks of memory. Now imaging billions of these little bits of memory. That means a lot of garbage to manage. Also, the discontinuities cause poor CPU cache performance.

<img src='https://raw.githubusercontent.com/data-fellas/scala-for-data-science/master/notebooks/images/JavaMemory.jpg' alt='Typical Java Object Layout' height='414' width='818'></img>

Instead, Tungsten uses a more efficient, cache-friendly encoding in a contiguous byte array. The first few bytes are bit flags to indicate which fields if any are null. Then comes 8 bytes/field for the non-null fields. If the field's value fits in 8 bytes (e.g., longs and doubles), then the value is inlined here. Otherwise, the value holds an offset to the final section, a variable-length sequence of bytes where longer objects, like ASCII strings, are stored.

<img src='https://raw.githubusercontent.com/data-fellas/scala-for-data-science/master/notebooks/images/TungstenMemory.jpg' alt='Tungsten Object Layout' height='264' width='818'></img>

## Scala REPL Weirdness

The way the Scala REPL (interpreter) compiles code leads to memory leaks, which cause problems when working with big data sets and long sessions. Imagine you write the following code in the REPL:

```scala
scala> val massiveArray = get8GBarray(...)
scala> // do some work
scala> massiveArray = getDifferent8GBarray(...)
```

You might think that the first "8GB array" will be nicely garbage collected when you reassign `massiveArray`. Not so. Here's a simplified view of the code the REPL generates for the _last_ line to pass to the compiler.

```scala
class LineN {
  class LineN_minus_1 {
    class LineN_minus_2 {
      ...
        class Line1 {
          val massiveArray = get8GBarray(...)
        }
      ...
    }
  }
  val massiveArray = getDifferent8GBarray(...)
}
```

Why? The JVM expects classes to be compiled into byte code, so the REPL syntheses classes for each line you evaluate (or group of lines when you use the `:paste ... ^D` feature).

Note that the overridden `massiveArray` shadows the original one, which is the trick the REPL uses to let you redefine variables, which would be prohibited by the compiler otherwise. Unfortunately, that leaves the shadowed reference attached to old data, so it can't be garbage collected, even though the REPL provides no way to ever refer to it again!
