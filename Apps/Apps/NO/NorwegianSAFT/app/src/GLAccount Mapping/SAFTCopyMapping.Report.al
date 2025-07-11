// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Utilities;

report 10671 "SAF-T Copy Mapping"
{
    UsageCategory = None;
    ProcessingOnly = true;
    Caption = 'SAF-T Copy Mapping';

    dataset
    {
        dataitem(Integer; Integer)
        {
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
            begin
                SAFTMappingHelper.CopyMapping(FromMappingRangeCode, ToMappingRangeCode, Replace);
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
                    field(MappingRangeID; FromMappingRangeCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Mapping Range Code';
                        ToolTip = 'Specifies the mapping range code to copy mapping from';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            NewSAFTMappingRange: Record "SAF-T Mapping Range";
                        begin
                            NewSAFTMappingRange.SetFilter(Code, '<>%1', ToMappingRangeCode);
                            if page.RunModal(0, NewSAFTMappingRange) = Action::LookupOK then
                                FromMappingRangeCode := NewSAFTMappingRange.Code;
                        end;
                    }
                    field(ReplaceControl; Replace)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replace Existing Mapping';
                        ToolTip = 'Specifies that the existing mapping will be replaced by the mapping range to copy.';
                    }
                }
            }
        }
    }

    var
        ToMappingRangeCode: Code[20];
        FromMappingRangeCode: Code[20];
        Replace: Boolean;

    procedure InitializeRequest(NewMappingRangeCode: Code[20])
    begin
        ToMappingRangeCode := NewMappingRangeCode;
    end;
}
