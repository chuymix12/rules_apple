# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Partial implementation for app assets validation."""

load(
    "@build_bazel_rules_apple//apple/internal:apple_product_type.bzl",
    "apple_product_type",
)
load(
    "@build_bazel_rules_apple//apple/internal:bundling_support.bzl",
    "bundling_support",
)
load(
    "@bazel_skylib//lib:partial.bzl",
    "partial",
)

visibility("//apple/...")

def _app_assets_validation_partial_impl(
        *,
        app_icons,
        launch_images,
        platform_prerequisites,
        product_type):
    """Implementation for the app assets processing partial."""

    if app_icons:
        if product_type == apple_product_type.messages_extension:
            message = ("Message extensions must use Messages Extensions Icon Sets " +
                       "(named .stickersiconset), not traditional App Icon Sets")
            bundling_support.ensure_single_xcassets_type(
                "app_icons",
                app_icons,
                "stickersiconset",
                message = message,
            )
        elif platform_prerequisites.platform_type == apple_common.platform_type.tvos:
            bundling_support.ensure_single_xcassets_type(
                "app_icons",
                app_icons,
                "brandassets",
            )
        else:
            bundling_support.ensure_single_xcassets_type(
                "app_icons",
                app_icons,
                "appiconset",
            )

    if launch_images:
        bundling_support.ensure_single_xcassets_type(
            "launch_images",
            launch_images,
            "launchimage",
        )

    return struct()

def app_assets_validation_partial(
        *,
        app_icons = [],
        launch_images = [],
        platform_prerequisites,
        product_type):
    """Constructor for the app assets validation partial.

    This partial validates the given app_icons and launch_images are correct for the current
    product type.

    Args:
        app_icons: List of files that represents the App icons.
        launch_images: List of files that represent the launch images.
        platform_prerequisites: Struct containing information on the platform being targeted.
        product_type: Product type identifier used to describe the current bundle type.

    Returns:
        A partial that validates app assets.
    """
    return partial.make(
        _app_assets_validation_partial_impl,
        app_icons = app_icons,
        launch_images = launch_images,
        platform_prerequisites = platform_prerequisites,
        product_type = product_type,
    )
