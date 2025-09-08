// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Foundation.DataSearch;

using Microsoft.Foundation.DataSearch;
using Microsoft.Inventory.Intrastat;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.Utilities;

codeunit 139508 "Test Data Search On Archives"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Search Events", 'OnGetFieldNoForTableType', '', true, true)]
    local procedure OnGetFieldNoForTableType(TableNo: Integer; var FieldNo: Integer)
    begin
        case TableNo of
            Database::"Sales Header Archive", Database::"Sales Line Archive":
                FieldNo := 1;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Search Events", 'OnGetParentTable', '', true, true)]
    local procedure OnGetParentTable(SubTableNo: Integer; var ParentTableNo: Integer)
    begin
        case SubTableNo of
            Database::"Sales Line Archive":
                ParentTableNo := Database::"Sales Header Archive";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Search Events", 'OnGetListPageNo', '', true, true)]
    local procedure OnGetListPageNo(TableNo: Integer; TableType: Integer; var PageNo: Integer)
    var
        SalesDocumentType: Enum "Sales Document Type";
    begin
        case TableNo of
            Database::"Sales Header Archive":
                case TableType of
                    SalesDocumentType::Order.AsInteger():
                        PageNo := Page::"Sales Order Archives";
                    SalesDocumentType::"Blanket Order".AsInteger():
                        PageNo := Page::"Blanket Sales Order Archives";
                    SalesDocumentType::Quote.AsInteger():
                        PageNo := Page::"Sales Quote Archives";
                    else
                        PageNo := Page::"Sales List Archive";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Search Events", 'OnGetCardPageNo', '', true, true)]
    local procedure OnGetCardPageNo(TableNo: Integer; TableType: Integer; var PageNo: Integer)
    var
        SalesDocumentType: Enum "Sales Document Type";
    begin
        case TableNo of
            Database::"Sales Header Archive":
                case TableType of
                    SalesDocumentType::Order.AsInteger():
                        PageNo := Page::"Sales Order Archive";
                    SalesDocumentType::"Blanket Order".AsInteger():
                        PageNo := Page::"Blanket Sales Order Archive";
                    SalesDocumentType::Quote.AsInteger():
                        PageNo := Page::"Sales Quote Archive";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Search Events", 'OnMapLineRecToHeaderRec', '', true, true)]
    local procedure OnMapLineRecToHeaderRec(var LineRecRef: RecordRef; var HeaderRecRef: RecordRef)
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesLineArchive: Record "Sales Line Archive";
    begin
        if LineRecRef.Number <> Database::"Sales Line Archive" then
            exit;
        LineRecRef.SetTable(SalesLineArchive);
        SalesHeaderArchive.Get(SalesLineArchive."Document Type", SalesLineArchive."Document No.", SalesLineArchive."Doc. No. Occurrence", SalesLineArchive."Version No.");
        HeaderRecRef.GetTable(SalesHeaderArchive);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Search Events", 'OnAfterGetRolecCenterTableList', '', true, true)]
    local procedure OnAfterGetRolecCenterTableList(RoleCenterID: Integer; var ListOfTableNumbers: List of [Integer])
    begin
        if not ListOfTableNumbers.Contains(Database::"Sales Header Archive") then
            ListOfTableNumbers.Add(Database::"Sales Header Archive");
        if not ListOfTableNumbers.Contains(Database::"Sales Line Archive") then
            ListOfTableNumbers.Add(Database::"Sales Line Archive");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Search Events", 'OnGetExcludedRelatedTableField', '', true, true)]
    local procedure OnGetExcludedRelatedTableField(RelatedTableNo: Integer; var IsExcluded: Boolean)
    begin
        IsExcluded := IsExcluded or (RelatedTableNo in [Database::"Customer Price Group", Database::"Work Type", Database::"Transport Method"]);
    end;
}
