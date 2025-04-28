// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 10544 "Create Tenant Data US"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Contoso Tenant Data", 'OnAfterCreateTenantData', '', false, false)]
    local procedure CreateTenantData()
    begin
        InsertMediaFiles();
    end;

    local procedure InsertMediaFiles()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATClassifications.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATCustomUnits.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATTransferReasons.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATCountry_Codes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATPayment_Methods.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATPayment_Terms.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATRelationship_Types.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATTax_Schemes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATU_of_M.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATUse_Codes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'CFDICancellationReasons.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'CFDIExportCodes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'CFDISubjectsToTax.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATIncoterms.xml');

        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATFederalMotorTransport.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATTrailerTypes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATPermissionTypes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATHazardousMaterials.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATPackagingTypes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATStates.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATMunicipalities.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATLocalities.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATSuburb1.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATSuburb2.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATSuburb3.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATSuburb4.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATWeightUnitsOfMeasure.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATMaterialTypes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATCustomsRegimes.xml');
        ContosoUtilities.InsertBLOBFromFile(FileDirectoryLbl, 'SATCustomsDocuments.xml');
    end;

    var
        FileDirectoryLbl: Label 'MXCatalogs/', Locked = true;
}
