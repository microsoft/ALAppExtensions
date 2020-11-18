// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2891 "Query Nav Validation Impl"
{
    Access = Internal;

    internal procedure ValidateNavigation(SourceQueryObjectId: Integer; TargetPageId: Integer; LinkingDataItemName: Text; var InputStringOK: Record "Query Navigation Validation"): Boolean
    var
        Args: DotNet ALQueryNavigationValidationArgs;
        Validator: DotNet ALQueryNavigationValidator;
        Result: DotNet ALQueryNavigationValidationResult;
    begin
        Args := Args.ALQueryNavigationValidationArgs();
        Validator := Validator.ALQueryNavigationValidator();

        Args.SourceQueryObjectId(SourceQueryObjectId);
        Args.TargetPageId(TargetPageId);
        Args.LinkingDataItemName(LinkingDataItemName);

        Result := Validator.Validate(Args);

        InputStringOK.Valid := Result.IsValid();

        if not InputStringOK.Valid then
            InputStringOK.Reason := Result.InvalidReason();

        exit(InputStringOK.Valid);
    end;
}