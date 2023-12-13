// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

tableextension 11782 "Analysis View CZL" extends "Analysis View"
{
    procedure GetCaptionClassCZL(DimNo: Integer): Text[250]
    var
        DimFilterTxt: Label '1,6,,Dimension %1 Filter', Comment = '%1 = Dimension No.';
    begin
        case DimNo of
            1:
                begin
                    if "Dimension 1 Code" <> '' then
                        exit('1,6,' + "Dimension 1 Code");
                    exit(StrSubstNo(DimFilterTxt, DimNo));
                end;
            2:
                begin
                    if "Dimension 2 Code" <> '' then
                        exit('1,6,' + "Dimension 2 Code");
                    exit(StrSubstNo(DimFilterTxt, DimNo));
                end;
            3:
                begin
                    if "Dimension 3 Code" <> '' then
                        exit('1,6,' + "Dimension 3 Code");
                    exit(StrSubstNo(DimFilterTxt, DimNo));
                end;
            4:
                begin
                    if "Dimension 4 Code" <> '' then
                        exit('1,6,' + "Dimension 4 Code");
                    exit(StrSubstNo(DimFilterTxt, DimNo));
                end;
        end;
    end;
}
