// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.Utilities;

codeunit 6387 "E-Doc. M365 Con. Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Classification Eval. Data", 'OnCreateEvaluationDataOnAfterClassifyTablesToNormal', '', false, false)]
    local procedure ClassifyDataSensitivity()
    var
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
    begin
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"OneDrive Setup");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"Outlook Setup");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"Sharepoint Setup");
    end;
}