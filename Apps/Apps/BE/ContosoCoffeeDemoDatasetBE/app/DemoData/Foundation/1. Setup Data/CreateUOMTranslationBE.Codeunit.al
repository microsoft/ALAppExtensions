// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.UOM;
using Microsoft.DemoTool.Helpers;

codeunit 11417 "Create UOM Translation BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateUnitOfMeasureTranslation();
    end;

    local procedure CreateUnitOfMeasureTranslation()
    var
        ContosoUnitOfMeasure: codeunit "Contoso Unit of Measure";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
        CreateLanguage: Codeunit "Create Language";
    begin
        UpdateUnitOfMeasureTranslation();

        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.Piece(), 'pi?áce', CreateLanguage.FRB());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.Piece(), 'stuk', CreateLanguage.NLB());
    end;

    local procedure UpdateUnitOfMeasureTranslation()
    var
        UnitOfMeasureTranslation: Record "Unit of Measure Translation";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
        CreateLanguage: Codeunit "Create Language";
    begin
        UnitOfMeasureTranslation.Get(CreateUnitofMeasure.Piece(), CreateLanguage.DEU());
        UnitOfMeasureTranslation.Validate(Description, 'st?ück');
        UnitOfMeasureTranslation.Modify(true);
    end;
}
