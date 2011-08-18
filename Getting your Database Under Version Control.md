author: @ScottWeinstein
title: Getting your database under version control
footer: @ScottWeinstein
subfooter: Lab49

#Getting your database under version control
And have sane deployments as a side-effect

#First some basics

#Why version control?

#Version Control
* VCS is “the database of record for your code”
* Allows non-locking concurrency between developers
* Freedom to explore
* Out of band documentation on changes in code
* Widely considered the most important tool (after the compiler/editor) in software development

#Why are databases hard to version control?

#Database and VCS
* Database combine 
	* Data
	* Schema (columns, relations, constraints)
	* Code (UDFs, Views, Stored Procs)
* Of the above, only Schema and Code are suitable for VCS
* But Schema and Data are tightly bound
	* The SQL Server syntax for Code does not lend itself to VCS

#TSQL is broken
* C# code as TSQL language designers would have it
	```C#
	update class ASillyExample {
	 create public string AUDF(int arg1)
	 {
	 }
	 drop public void AFunctionNoLongerUsed();
	}
	````

# Managing schema changes is hard
* For instance, replacing AssetType (varchar) with AssetTypeId (int, FK)
* The schema changes are declarative, but keeping the data consistent will require a sequence of steps
	* Create AssetType table
	* Populate with distinct values
	* Add AssetTypeId
	* Update with join
	* Drop old column or replace with computed column

#An approach
* Goals
	* Lets you see history of changes to code entities
	* Lets you manage, test, deploy
		* and avoid team confusion mistakes related to schema and data
* Does not guarantee that a copy of the production schema can be created from just code
* Available on GitHub
	* https://github.com/ScottWeinstein/PSIS


# An approach
* Requirements
	* A copy of the production database is available
* Code
	* Each entity gets one file
	* Consistent syntax to drop and create
	* A dbcompile tool deletes any entity that isn’t in the file system
	* A Db2Src tool helps get you started
	* Same tool is used to build the database locally and to deploy to production

* Schema
	* Implemented as a series of sequential steps. 
	* Each step is applied exactly once

* Data
	* Except for lookup tables and the like, not kept under version control


# Deployment
* The goal of deployment is to get the Prod database from current state to the new features state.
* Include source and deploy-database.ps1 with deployment package
* Run the deploy-database.ps1
* After a release, move exiting items in TableScripts to an archive dir

# Continuous integration
* Do this on the build server
* Rapid feedback
* Deployment to prod become low risk
* Depending on the size of your database, this may need to be a once an hour, or once a day activity
* The key to success here is to run it on a copy of production

# Potential pitfalls
* Allowing one-off changes to exist outside the VCS system
* Indulging team members who need to use their own special way
* Other tools can be used, provided there’s a common text based gold representation
