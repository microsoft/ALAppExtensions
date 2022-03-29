// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1907 "Camera and Media - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Camera Impl." = X,
                  Codeunit "Camera Page Impl." = X,
                  Codeunit "File Helper" = X,
                  Codeunit "Media Upload Page Impl." = X,
                  Codeunit Camera = X,
                  Page "Media Upload" = X,
#if CLEAN20                  
                  Page Camera = X;
#else
                  Page Camera = X,
                  Table "Temp Media" = X;
#endif
}
