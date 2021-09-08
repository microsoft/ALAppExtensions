Before you can run the tests in this extension, you must first publish two extensions. The only requirements are that you can compile them, and one extension must have a dependency on the other in the app.json dependency list. To save you some time we’ve provided two sample extensions for which we’ve set up the dependency. However, you can also create your own extensions and define the dependency yourself. If you do, in the app.json file for each extension, use the following appIDs for the main and dependent extensions:

-	Main: 9d939f81-be24-481f-9352-830c0346c171
-	Dependent: c4123d81-a537-4062-bdd4-7b9882bcc319 
 
The extensions we've provided are in the testArtifacts folder. To publish them, open PowerShell and run the following command: 

Publish-NAVApp
