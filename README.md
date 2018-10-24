# Microsoft AL application add-on and localization extensions for Microsoft Dynamics 365 Business Central
The purpose of this repository is to create a collaboration platform between Microsoft and our vibrant partner channel and community for the joint development of application extensions in the AL language.

Going forward, an increasing part of our application business logic will be modularized and extracted into extensions, which will be published onto this repository; this is true for both application add-ons as well as application localizations. The core application thereby becomes thinner, better extensible and better localizable. The extracted modules become open for contributions, are replaceable in the application with substitutes, serve as starting point for verticalizations of the modules or serve as samples for extension development in general.

The jointly developed extensions in this repository will be published by Microsoft to App Source and will be shipped with upcoming releases of [Microsoft Dynamics 365 Business Central](https://dynamics.microsoft.com/en-us/business-central).

## Contributing
This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## How to get started
1. Become familiar with development in AL. For more information, see https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-get-started.  
2. Choose the sandbox option that's right for you. For more information, see https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-sandbox-overview.  
3. Clone the repository where Microsoft extensions are available : https://github.com/Microsoft/ALAppExtensions.  
4. Objects are in the Microsoft ID range, which means you cannot upload the app to your sandbox. For the app to work you must renumber the object IDs (for more information, see https://blogs.msdn.microsoft.com/nav/2018/04/05/business-central-object-ranges/).  
    
    You can renumber objects in several ways. The following steps describe one of them.  
    
	1. Get the RenumberNavObjectIds tool from https://github.com/NAVDEMO/RenumberNavObjectIds.  
    2. Clone the project and open it in Visual Studio 2015. Build the project, and you are off to a good start.  
    3. Run the following PowerShell Script in PowerShell ISE:  
       ```
       Import-module "C:\...\RenumberObjectIds.dll"  
	   $RenumberList = @{}  
	   0..1000 | % { $RenumberList += @{ (1800+$_) = (80000+$_) } }  
	   0..20 | % { $RenumberList += @{ (136630+$_) = (82000+$_) } }  
		 
	   Renumber-NavObjectIds -SourceFolder "C:\...\C52012DataMigration\" -DestinationFolder "C:\...\C52012DataMigrationReID" -RenumberList $RenumberList -Verbose  
       ```
5. In Visual Studio Code, connect to your sandbox (follow the steps in the documentation that step 2 refers to) and open the C:\...\C52012DataMigrationReID folder. Now you are ready to go. You can modify the code and build your extension.  
6. To submit your changes, create a new branch. Remember to revert the change of IDs, and then create a pull request.  
