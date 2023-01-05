// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 8724 "Time Zone Info Initializer"
{
    Access = Internal;

    procedure InitializeTimeZoneInfo(TimeZoneId: Text; var TimeZoneInfoDotNet: DotNet TimeZoneInfo)
    begin
        if not TryInstantiateTimeZoneInfo(TimeZoneId, TimeZoneInfoDotNet) then
            ThrowInvalidTimeZoneIdError(TimeZoneId);
    end;

    [TryFunction]
    local procedure TryInstantiateTimeZoneInfo(TimeZoneId: Text; var TimeZoneInfoDotNet: DotNet TimeZoneInfo)
    begin
        TimeZoneInfoDotNet := TimeZoneInfoDotNet.FindSystemTimeZoneById(TimeZoneId);
    end;

    local procedure ThrowInvalidTimeZoneIdError(TimeZoneId: Text)
    var
        InvalidTimeZoneIdErr: Label 'You have passed an invalid timezone ID (%1). Please reference the time zone list for supported time zone IDs.', Comment = '%1 = The invalid time zone ID passed to the procedure.';
    begin
        Error(InvalidTimeZoneIdErr, TimeZoneId);
    end;
}