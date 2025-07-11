// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

page 18694 "TDS Section Card"
{
    PageType = Card;
    SourceTable = "TDS Section";
    Caption = 'TDS Section';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the section codes under which tax has been deducted.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the description of nature of payment.';
                }
                field(ecode; Rec.ecode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'eTDS';
                    ToolTip = 'Specify the section code to be used in the return.';
                }
            }
        }
    }
}
