// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132922 "ABS Helper Functionality Test"
{
    Subtype = Test;

    [Test]
    procedure TestDateConversion()
    var
        SourceString: Text;
        TargetDate: DateTime;
        CompareDate: DateTime;
    begin
        CompareDate := CreateDateTime(DMY2Date(24, 5, 2021), 142527T);
        SourceString := 'Mon, 24 May 2021 12:25:27 GMT';
        Evaluate(TargetDate, SourceString);

        Assert.AreEqual(TargetDate, CompareDate, 'Dates are not equal');
    end;

    var
        Assert: Codeunit "Library Assert";
}