// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.RoleCenters;
using Microsoft.Purchases.Document;

tableextension 6101 "E-Doc. Account Payable Cue" extends "Account Payable Cue"
{
    fields
    {
        field(6100; "Unprocessed E-Documents"; Integer)
        {
            Caption = 'Unprocessed E-Documents';
            ToolTip = 'Number of unprocessed E-Documents';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("E-Document" where(Status = filter("In Progress" | Error)));
        }
        field(6101; "Linked Purchase Orders"; Integer)
        {
            Caption = 'Linked Purchase Orders';
            ToolTip = 'Number of linked purchase orders';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Purchase Header" where("Document Type" = filter("Order"),
                                                        "E-Document Link" = filter('<>00000000-0000-0000-0000-000000000000')));
        }
        field(6102; "E-Documents with Errors"; Integer)
        {
            Caption = 'E-Documents with Errors';
            ToolTip = 'Number of E-Documents with errors';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("E-Document" where(Status = filter(Error)));
        }
        //TODO Shouldnt we add Processing date to calculate when was the edocs processed?
        field(6103; "Processed E-Documents TM"; Integer)
        {
            Caption = 'Processed E-Documents This Month';
            ToolTip = 'Number of processed E-Documents this month';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("E-Document" where(Status = filter(Processed),
                                                "Posting Date" = field("Posting Date Filter")));
        }
    }
}
