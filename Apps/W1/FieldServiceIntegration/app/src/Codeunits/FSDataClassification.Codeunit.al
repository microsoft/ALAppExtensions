// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Utilities;
using System.Privacy;

codeunit 6614 "FS Data Classification"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Classification Eval. Data", 'OnCreateEvaluationDataOnAfterClassifyTablesToNormal', '', false, false)]
    local procedure OnClassifyTables()
    begin
        ClassifyTables();
    end;


    local procedure ClassifyTables()
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Connection Setup");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Bookable Resource");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Bookable Resource Booking");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS BookableResourceBookingHdr");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Customer Asset");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Customer Asset Category");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Project Task");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Resource Pay Type");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Warehouse");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Work Order");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Work Order Product");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Work Order Service");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Work Order Incident");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Work Order Substatus");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FS Work Order Type");
    end;
}