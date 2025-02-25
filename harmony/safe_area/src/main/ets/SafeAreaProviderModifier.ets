/**
 * MIT License
 *
 * Copyright (C) 2023 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import { TransformMatrix } from '@rnoh/react-native-openharmony';
import { SafeAreaProviderDescriptorWrapper } from './SafeAreaProvider';
import matrix4 from '@ohos.matrix4';

export class SafeAreaProviderModifier implements AttributeModifier<StackAttribute> {
  private constructor() {
  }

  private static instance: SafeAreaProviderModifier;
  protected descriptorWrapper: SafeAreaProviderDescriptorWrapper | undefined = undefined

  public static getInstance(): SafeAreaProviderModifier {
    if (!SafeAreaProviderModifier.instance) {
      SafeAreaProviderModifier.instance = new SafeAreaProviderModifier();
    }
    return SafeAreaProviderModifier.instance;
  }

  setDescriptor(descriptorWrapper: SafeAreaProviderDescriptorWrapper | undefined): SafeAreaProviderModifier {
    this.descriptorWrapper = descriptorWrapper;
    return SafeAreaProviderModifier.instance;
  }

  getHitTestMode() {
    switch (this.descriptorWrapper?.pointerEvents) {
      case "none":
        return HitTestMode.None
      case "box-none":
        return HitTestMode.None
      case "box-only":
        return HitTestMode.Block
      default:
        return HitTestMode.Default
    }
  }

  getBorderStyle(): BorderStyle {
    switch (this.descriptorWrapper?.borderStyle) {
      case "dashed":
        return BorderStyle.Dashed
      case "dotted":
        return BorderStyle.Dotted
      default:
        return BorderStyle.Solid
    }
  }

  getTransform(): undefined | matrix4.Matrix4Transit {
    const descriptorWrapper = this.descriptorWrapper
    if (!descriptorWrapper) {
      return undefined
    }
    const rawTransformationMatrix = descriptorWrapper.rawTransformationMatrix.slice()
    rawTransformationMatrix[12] = vp2px(rawTransformationMatrix[12]);
    rawTransformationMatrix[13] = vp2px(rawTransformationMatrix[13]);
    rawTransformationMatrix[14] = vp2px(rawTransformationMatrix[14]);
    return matrix4.init(rawTransformationMatrix as TransformMatrix)
  }

  applyNormalAttribute(instance: StackAttribute): void {
    instance.width(this.descriptorWrapper?.width);
    instance.height(this.descriptorWrapper?.height);
    instance.position(this.descriptorWrapper?.positionRelativeToParent);

    if (this.descriptorWrapper?.backgroundColor !== '#00000000') {
      instance.backgroundColor(this.descriptorWrapper?.backgroundColor)
    }
    if (JSON.stringify(this.descriptorWrapper?.borderWidth) !== '{}') {
      instance.borderWidth(this.descriptorWrapper?.borderWidth)
    }
    if (JSON.stringify(this.descriptorWrapper?.borderColor) !== '{"top":"#00000000","left":"#00000000","right":"#00000000","bottom":"#00000000"}') {
      instance.borderColor(this.descriptorWrapper?.borderColor)
    }
    if (JSON.stringify(this.descriptorWrapper?.borderRadius) !== '{}') {
      instance.borderRadius(this.descriptorWrapper?.borderRadius)
    }
    if (this.descriptorWrapper?.borderStyle === 'dashed' || this.descriptorWrapper?.borderStyle === 'dotted') {
      instance.borderStyle(this.getBorderStyle())
    }
    if (this.descriptorWrapper?.opacity !== 1) {
      instance.opacity(this.descriptorWrapper?.opacity)
    }
    // if (this.descriptorWrapper?.transformStringify !== '[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]') {
    //   instance.transform(this.getTransform())
    // }
    if (this.descriptorWrapper?.isClipping) {
      instance.clip(this.descriptorWrapper?.isClipping)
    }
    let hitTestBehavior: HitTestMode = this.getHitTestMode();
    if (hitTestBehavior !== HitTestMode.Default) {
      instance.hitTestBehavior(hitTestBehavior)
    }
    if (this.descriptorWrapper?.shadow) {
      instance.shadow(this.descriptorWrapper?.shadow)
    }
  }
}