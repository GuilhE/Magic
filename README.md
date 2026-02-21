<img src="/media/icon.png" width="100" align="right"></br></br>

# Magic

[![Android Weekly](https://androidweekly.net/issues/issue-647/badge)](https://androidweekly.net/issues/issue-647) [![Featured in Kotlin Weekly - Issue #378](https://img.shields.io/badge/Featured_in_Kotlin_Weekly-Issue_%23478-7878b4)](https://mailchi.mp/kotlinweekly/kotlin-weekly-478) 

KMP sample project acting as a playground to illustrate what's discussed in this article:
<p>
 <a href="https://guidelgado.medium.com/fa8cb2c1aa92"><img src="/media/banner.png" width="692"></a></br>
</p>

> [!NOTE]
> The `main` branch currently uses `swiftExport`. For Objective-C/Swift interoperability (as mentioned in the article), please use the `objc-interop` tag.
> A new article covering the `swiftExport` approach will be published in the near future.

## Details

### Shared

The modules `data-models`, `core-database`, and `core-network` are independent, while `data-managers` depends on all three.
Each module is responsible for providing its own Dependency Injection (DI) logic, but the `core-di` module manages the root DI system, utilised by all platforms.
This is why the `core-di` module depends on all other modules and will also contain the Objective-C framework settings.  

These five modules constitute the Shared Data Layer.

### Platforms

#### Android

The `MagicApp` serves as the entry point and includes the setup for DI. There's no Domain Layer and `Shared Data Layer` is the Data Layer itself. Finally, the `presentation` contains all the logic related to the UI Layer.

To run it `./gradlew :androidApp:installDebug`

#### iOS

The `App` package serves as the entry point and includes the setup for DI. 
The `Core` defines the DI protocols and container. The `Data` acts as a bridge between the App's Data Layer and the Shared Data Layer, where the implementation logic resides. 
The `Domain` contains the bridge protocols and data structures, and also the app protocols. Finally, the `Presentation` contains all the logic related to the UI Layer.

To run it open `iosApp/Magic.xcodeproj` in Xcode and run standard configuration or use [KMP plugin](https://plugins.jetbrains.com/plugin/14936-kotlin-multiplatform) for Android Studio and choose `iosApp` in `run configurations`.

<p align="center">
 <img src="/media/deck-combine.gif">   
</p>

## LICENSE

Copyright (c) 2024-present GuilhE

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy
of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under
the License.
