MoneyTypes = {
    ['cash'] = {
        [Framework.ESX] = 'money',
        [Framework.QBCore] = 'cash',
        [Framework.QBOX] = 'cash',
        [Framework.NDCore] = 'cash'
    },
    ['bank'] = {
        [Framework.ESX] = 'bank',
        [Framework.QBCore] = 'bank',
        [Framework.QBOX] = 'bank',
        [Framework.NDCore] = 'bank'
    },
    ['black_money'] = {
        [Framework.ESX] = 'black_money',
        [Framework.QBCore] = 'crypto',
        [Framework.QBOX] = 'crypto',
        [Framework.NDCore] = nil
    }
}

exports('getMoneyType', function(moneyType)
    return MoneyTypes[moneyType][Config.Framework]
end)

exports('getMoneyTypes', function()
    return MoneyTypes
end)