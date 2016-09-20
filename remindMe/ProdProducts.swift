//
//  ProdProducts.swift
//  Prod
//
//  Created by Duane Stoltz on 20/09/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

public struct ProdProducts {
    private static let Prefix = "com.coconutdust.prod."
    public static let PremiumTest = Prefix + "premiumTest"
    private static let productIdentifiers: Set<ProductIdentifier> = [ProdProducts.PremiumTest]
    public static let store = IAHelper(productIds: ProdProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
