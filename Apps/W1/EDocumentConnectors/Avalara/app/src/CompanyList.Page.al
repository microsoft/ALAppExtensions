#pragma warning disable AS0035
#pragma warning disable AS0026
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

page 6373 "Company List"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    SourceTable = "Avalara Company";
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(CompanyList)
            {
                field(CompanyName; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Avalara company name';
                }
            }
        }
    }

    procedure SetRecords(var AvalaraCompany: Record "Avalara Company" temporary)
    begin
        if AvalaraCompany.FindSet() then
            repeat
                Rec.TransferFields(AvalaraCompany);
                Rec.Insert();
            until AvalaraCompany.Next() = 0;
    end;
}
#pragma warning restore AS0026
#pragma warning restore AS0035