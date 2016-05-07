# Scala for Data Science

These notebooks and other material are for the [Scala Days 2016](http://www.scaladays.org/) and [Strata London 2016](http://conferences.oreilly.com/strata/hadoop-big-data-eu/public/schedule/detail/49739) talks by [Andy Petrella](mailto:noootsab@data-fellas.guru) and [Dean Wampler](dean.wampler@lightbend.com) on why Scala is a great language for Data Science.

The talk is organized as a series of notebooks, install [Spark Notebook](http://spark-notebook.io/), then run it with the following command, where we assume that `$SPARK_NOTEBOOK_HOME` is where you installed it and you are running the command from this directory, `$PWD` (the full path is required for the `notebooks` argument):

```shell
$SPARK_NOTEBOOK_HOME/bin/spark-notebook -Dmanager.notebooks.dir=$PWD/notebooks
```

For Windows, use the following:
```
%SPARK_NOTEBOOK_HOME%\bin\spark-notebook -Dmanager.notebooks.dir=%CD%\notebooks
```

Then open the notebooks (e.g., _WhyScala_). To evaluate all the cells in a notebook, use the _Cell > Run All_ menu item.

