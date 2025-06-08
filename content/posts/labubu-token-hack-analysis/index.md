+++
date = '2025-06-08T16:24:51+08:00'
draft = false
title = 'LABUBU Token Hack Analysis'
author = 'islu'
summary = 'LABUBU 在 BSC 的可疑攻擊，造成約 $11.9K 的損失'
description = ''
keywords = []
categories = ['📝 Analysis']
tags = ['bsc', 'solidity']

[cover]
image = "images/labubu.jpg"
alt = "labubu"
caption = "[David Kristianto - Unsplash](https://unsplash.com/photos/a-cute-stuffed-animal-sits-on-a-comfortable-chair-rXczQOaeru4)"
relative = false
hiddenInList = true
hiddenInSingle = false
+++

## Background

根據 [@TenArmorAlert](https://x.com/TenArmorAlert/status/1866481066610958431) 回報檢測到涉及 LABUBU 在 BSC 的可疑攻擊，造成約 $11.9K 的損失

- **Attacker:** [0x27441](https://bscscan.com/address/0x27441c62dbe261fdf5e1feec7ed19cf6820d583b)
- **Attack Tx:** [0xb06df](https://bscscan.com/tx/0xb06df371029456f2bf2d2edb732d1f3c8292d4271d362390961fdcc63a2382de)
- **Attack Contract:** [0x2ff0c](https://bscscan.com/address/0x2ff0cc42e513535bd56be20c3e686a58608260ca)
- **Vulnerable Contract:** [0x2ff96](https://bscscan.com/token/0x2ff960f1d9af1a6368c2866f79080c1e0b253997)

## Root Cause

- `_transfer()` 計算餘額邏輯錯誤，當 `sender` 跟 `recipient` 為相同地址時實際上不會減少反而會增加
- 有問題的程式碼，這邊假設
    - `sender = recipient`
    - `amount = 10`

```solidity
function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "Xfer from zero addr");
    require(recipient != address(0), "Xfer to zero addr");

    uint256 senderBalance = _balances[sender]; // 10
    uint256 recipientBalance = _balances[recipient]; // 10

    uint256 newSenderBalance = SafeMath.sub(senderBalance, amount); // 10 - 10 = 0
    if (newSenderBalance != senderBalance) { // 0 != 10
        _balances[sender] = newSenderBalance; // sender -> 0
    }

    uint256 newRecipientBalance = recipientBalance.add(amount); // 10 + 10 = 20
    if (newRecipientBalance != recipientBalance) { // 20 != 10
        _balances[recipient] = newRecipientBalance; // recipient = sender -> 20
    }

    if (_balances[sender] == 0) {
        _balances[sender] = 16;
    }

    emit Transfer(sender, recipient, amount);
}
```

- 另外就是 `if (_balances[sender] == 0)` 如果成立會直接將餘額設定成 `16`，這段程式碼就比較奇怪，不過不是本次事件的原因

## Attack Analysis

- 閃電貸借出 LABUBU
- 呼叫 `transfer()` 不斷自己轉帳給自己
- 將閃電貸借出的 LABUBU 還回去
- 將得到的 LABUBU 到 PancakeSwap 兌換成 WBNB

攻擊流程 [PoC](https://github.com/SunWeb3Sec/DeFiHackLabs/pull/907)

## How To Fix

- 檢查是否為相同的地址
- 取得餘額不要使用變數，直接讀取 `_balances[recipient]`
