# Scala for Data Science

The enclosed notebook and other material are for the [Scala Days 2016](http://www.scaladays.org/) and [Strata London 2016](http://conferences.oreilly.com/strata/hadoop-big-data-eu/public/schedule/detail/49739) talks by [Andy Petrella](mailto:noootsab@data-fellas.guru) and [Dean Wampler](dean.wampler@lightbend.com) on why Scala is a great language for Data Science.

The talk includes a notebook for [Spark Notebook](http://spark-notebook.io/), which provides a notebook metaphor for interactive Spark development using Scala. If you aren't familiar with the idea of a notebook interface, think of it as an enhanced REPL that makes it easy to edit and run (or rerun) code, plot results, mix in markdown-based documentation, etc.

However, if you don't want to go to the trouble of installing and using [Spark Notebook](http://spark-notebook.io/), there are Markdown and PDF versions of the same content in the `notebooks` directory.

Otherwise, install [Spark Notebook](http://spark-notebook.io/), version 0.6.3 or later. You can use either Scala 2.10 or 2.11. In the commands below, we'll assume the root directory of this installation is `/path/to/spark-notebook`. Just use your real path instead. Due to a bug in library path handling, **you must start Spark Notebook from this directory**. 

We'll also use `/path/to/scala-for-data-science` as the path to your local clone of this Git repo. Again, substitute the real path...

There is one environment variable that you **must** define, `NOTEBOOKS_DIR`. Run the following commands to define this variable and start Spark Notebook.

For Linux or OSX, use the following:
```
export NOTEBOOKS_DIR=/path/to/scala-for-data-science/notebooks
cd /path/to/spark-notebook
bin/spark-notebook
```

For Windows, use the following:
```
set NOTEBOOKS_DIR=c:\path\to\scala-for-data-science\notebooks
cd \path\to\spark-notebook
bin\spark-notebook
```

Open a browser window to [localhost:9000](http://localhost:9000). Then click the link to open the notebook [WhyScala](http://localhost:9000/notebooks/WhyScala.snb). 

To evaluate all the cells in a notebook, use the _Cell > Run All_ menu item. You can evaluate one cell at a time with the ▶︎ button on the toolbar, or use "shift+return". Both options run the currently-selected cell and advance to the next cell. Note that the notebook copy in the repo includes the output from a run.

Grab the slides for the rest of the presentation [here](https://docs.google.com/a/data-fellas.guru/presentation/d/1d7vT3mgo4ppHXHtKRQjcVW8SsMs3PeRAkq3PHRgWKaQ/edit?usp=sharing).


