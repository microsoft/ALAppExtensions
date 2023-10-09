// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.CodeCoverage;

using System.Tooling;

xmlport 130470 "Code Coverage Results"
{
    Direction = Export;
    Format = VariableText;
    FieldDelimiter = '';
    FieldSeparator = ',';
    TableSeparator = '<NewLine>';
    TextEncoding = UTF16;

    schema
    {
        textelement(CodeCoverageResults)
        {
            tableelement(ALCodeCoverage; "Code Coverage")
            {
                fieldelement(ALObjectType; ALCodeCoverage."Object Type")
                {
                }
                fieldelement(ALObjectID; ALCodeCoverage."Object ID")
                {
                }
                fieldelement(ALLineNumber; ALCodeCoverage."Line No.")
                {
                }

                textelement(CoverageStatus)
                {
                }
                fieldelement(ALNumberOfHits; ALCodeCoverage."No. of Hits")
                {
                }

                // Could I add quotes (") surrounding?
                trigger OnAfterGetRecord()
                var
                    ALCodeCoverageMgt: Codeunit "AL Code Coverage Mgt.";
                begin
                    if ALCodeCoverageMgt.CoverageFromInternals(ALCodeCoverage) then
                        currXMLport.Skip();

                    // Adjust the "Code Coverage Status" for AzureDevOps
                    case ALCodeCoverage."Code Coverage Status" of
                        ALCodeCoverage."Code Coverage Status"::Covered:
                            CoverageStatus := AzureDevOpsCoveredLbl;
                        ALCodeCoverage."Code Coverage Status"::NotCovered:
                            CoverageStatus := AzureDevOpsNotCoveredLbl;
                        ALCodeCoverage."Code Coverage Status"::PartiallyCovered:
                            CoverageStatus := AzureDevOpsPartiallyCoveredLbl;
                    end;
                end;
            }
        }
    }

    var
        AzureDevOpsCoveredLbl: Label '0', Locked = true;
        AzureDevOpsNotCoveredLbl: Label '1', Locked = true;
        AzureDevOpsPartiallyCoveredLbl: Label '2', Locked = true;
}