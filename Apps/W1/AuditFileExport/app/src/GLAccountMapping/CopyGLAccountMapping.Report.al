// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Utilities;

report 5260 "Copy G/L Account Mapping"
{
    UsageCategory = None;
    ProcessingOnly = true;
    Caption = 'Copy G/L Account Mapping';

    dataset
    {
        dataitem(Integer; Integer)
        {
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                GLAccountMappingHelper: Codeunit "Audit Mapping Helper";
            begin
                GLAccountMappingHelper.CopyMapping(FromMappingCode, ToMappingCode, Replace);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(MappingCode; FromMappingCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'G/L Account Mapping Code';
                        ToolTip = 'Specifies the general ledger account mapping code to copy mapping from.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            NewGLAccountMappingHeader: Record "G/L Account Mapping Header";
                        begin
                            NewGLAccountMappingHeader.SetFilter(Code, '<>%1', ToMappingCode);
                            if Page.RunModal(0, NewGLAccountMappingHeader) = Action::LookupOK then
                                FromMappingCode := NewGLAccountMappingHeader.Code;
                        end;
                    }
                    field(ReplaceControl; Replace)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replace Existing Mapping';
                        ToolTip = 'Specifies that the existing mapping will be replaced by the mapping to copy.';
                    }
                }
            }
        }
    }

    var
        ToMappingCode: Code[20];
        FromMappingCode: Code[20];
        Replace: Boolean;

    procedure InitializeRequest(NewGLAccMappingCode: Code[20])
    begin
        ToMappingCode := NewGLAccMappingCode;
    end;
}
