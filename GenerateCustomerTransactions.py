# generate customer trans and write to a csv file
# add 5 customers to learn and 5 bad customers at the end
import numpy as np
import pandas as pd
import datetime

# print time log
def pt(s=''):
    i = datetime.datetime.now()
    print(i.isoformat() + " " + s)


# portfolio characteristics
data = {'Segment': ['Retail', 'Wealth'],
        'TxLow': [1, 3],
        'TxHigh': [4, 8],
        'DbLow': [.7, .4],
        'DbHigh': [.9, .6],
        'TxValLow': [10, 1000],
        'TxValHigh': [500, 10000],
        }
df = pd.DataFrame(data)

# Parameters
customer_segment = ['Retail', 'Wealth']
customer_account = ['Current', 'Savings']
tx_type = ['CR', 'DR']
tx_product = ['Cash', 'Wire', 'Check']
# how many customers we want to create
number_of_customers = 1000
cust = int(number_of_customers / 2)  # 2 accounts
alert_every = 1000000
cid = 10  # start at 10 so we can fabricate some synthetic segments
rng = pd.date_range('2015-01-01', periods=12, freq='M')
tx_count = 0

pt("Start Customer / Txn Generation")
csv_output_file = open('custtxn.csv', 'w')


def gencusttxns(pcu, pcs, pca, pdt, ptp, pTxLow, pTxHigh, pDbLow, pDbHigh, pTxValLow, pTxValHigh):
    # generate a random number of transactions according to the distribution above
    # use p as the counter
    global tx_count

    # pick number of transactions in the range for this segment
    ntxn = np.random.randint(pTxLow, pTxHigh)

    # work out the % of debits - random within range - and work out the # debit / credit remaining credits
    pcdebits = DbLow + (pDbHigh - pDbLow) * np.random.random_sample()
    ndebits = int(ntxn * pcdebits)
    ncredits = int(ntxn - ndebits)

    # with a value between the lower and upper values say $100 and $150
    txndb = np.random.randint(pTxValLow, pTxValHigh, ndebits)
    txncr = np.random.randint(pTxValLow, pTxValHigh, ncredits)

    # use this one for timestamp
    scommon = "C" + format(pcu, "08d") + "," + pcs + "," + pca + "," + str(pdt) + "," + ptp
    for txn in range(ndebits):
        # s = "Cust" + str(cid) + "," + cs + "," + ca + "," + str(dt) + "," + tp + ",DB," + str(txndb[txn]) + "\n"
        # print (s)
        tx_count += 1
        if tx_count % alert_every == 0:
            pt("Txn: " + str(tx_count))
        csv_output_file.write(scommon + ",DB," + str(txndb[txn]) + "\n")

    # then credits
    for txn2 in range(ncredits):
        csv_output_file.write(scommon + ",CR," + str(txncr[txn2]) + "\n")
        tx_count += 1
        if tx_count % alert_every == 0:
            pt("Txn: " + str(tx_count))
    return ntxn


# build the list
for cs in customer_segment:
    # get the customer segment attributes
    TxLow = int(df[df['Segment'] == cs]['TxLow'])  # ': [10, 1000, 100000],
    TxHigh = int(df[df['Segment'] == cs]['TxHigh'])
    DbLow = float(df[df['Segment'] == cs]['DbLow'])
    DbHigh = float(df[df['Segment'] == cs]['DbHigh'])
    TxValLow = int(df[df['Segment'] == cs]['TxValLow'])
    TxValHigh = int(df[df['Segment'] == cs]['TxValHigh'])
    for cu in range(cust):
        for ca in customer_account:
            for dt in rng:
                for tp in tx_product:
                    # generate a random number of transactions between lower, upper, split between DR/CR, ...
                    txngen = gencusttxns(cid, cs, ca, dt, tp, TxLow, TxHigh, DbLow, DbHigh, TxValLow, TxValHigh)
        cid += 1
print("Transaction Count:", tx_count)

# seed 5 customers with behaviour for non / retail (to learn)
# now add a standouts (suspects) called retail, low vol / high value transactions
added = 0
for dt in rng:
    for tp in tx_product:
        added += gencusttxns(0, 'LowVolHighVal', 'Current', dt, tp, 3, 6, .8, .7, 100000, 150000)
        added += gencusttxns(1, 'HighVolLowVal', 'Current', dt, tp, 100, 110, .8, .7, 10, 50)
        added += gencusttxns(2, 'HighVolHighVal', 'Current', dt, tp, 100, 110, .8, .7, 9500, 9999)
pt("Added + " + str(added))
tx_count += added

# add a standout (suspect) called retail, but moving funds through multiple accounts low vol / low values transactions
added = 0
for dt in rng:
    for tp in tx_product:
        for acc in ['Current', 'Savings', 'Mortgage', 'Acc1', 'Acc2',
                    'Acc3', 'Acc4', 'Acc5', 'Acc6', 'Acc7', 'Acc8', 'Acc9', 'Acc10']:
            added += gencusttxns(3, 'MultiAccount', acc, dt, tp, 5, 10, .8, .7, 10, 30)
pt("Added + " + str(added))
tx_count += added

# add a standout (suspect) called retail, but moving funds through multiple products low vol / low values transactions
added = 0
for dt in rng:
    for tp in ['Cash', 'Wire', 'Check', 'Bonds', 'EQSettle', 'Shares', 'IntlPay', 'Dividend', 'CashBox', 'ONDeposit',
               'DomPay', 'Forex', 'Loan', 'TermDep', 'CreditCard', 'DebitCard']:
        added += gencusttxns(4, 'MultiProduct', 'Current', dt, tp, 5, 10, .8, .7, 10, 30)
pt("Added + " + str(added))
tx_count += added

# now add change in behaviour for customers 10, 11, 12
added = 0
for dt in rng:
    for tp in tx_product:
        added += gencusttxns(10, 'Retail', 'Current', dt, tp, 3, 6, .8, .7, 100000, 150000)
        added += gencusttxns(11, 'Retail', 'Current', dt, tp, 100, 110, .8, .7, 10, 50)
        added += gencusttxns(12, 'Retail', 'Current', dt, tp, 100, 110, .8, .7, 9500, 9999)
pt("Added + " + str(added))
tx_count += added

# now create 5 new customers (December) who call themselves retail
# now add a standout (suspect) called retail, high vol / low values transactions
rng = pd.date_range('2015-12-01', periods=4, freq='W')
added = 0
for dt in rng:
    for tp in tx_product:
        added += gencusttxns(5000000, 'Retail', 'Current', dt, tp, 3, 6, .8, .7, 100000, 150000)
        added += gencusttxns(5000001, 'Retail', 'Current', dt, tp, 100, 110, .8, .7, 10, 50)
        added += gencusttxns(5000002, 'Retail', 'Current', dt, tp, 100, 110, .8, .7, 9500, 9999)
pt("Added + " + str(added))
tx_count += added

# add a standout (suspect) called retail, but moving funds through multiple accounts low vol / low values transactions
added = 0
for dt in rng:
    for tp in tx_product:
        for acc in ['Current', 'Savings', 'Mortgage', 'Acc1', 'Acc2',
                    'Acc3', 'Acc4', 'Acc5', 'Acc6', 'Acc7', 'Acc8', 'Acc9', 'Acc10']:
            added += gencusttxns(5000003, 'Retail', acc, dt, tp, 5, 10, .8, .7, 10, 30)
pt("Added + " + str(added))
tx_count += added

# add a standout (suspect) called retail, but moving funds through multiple products low vol / low values transactions
added = 0
for dt in rng:
    for tp in ['Cash', 'Wire', 'Check', 'Bonds', 'EQSettle', 'Shares', 'IntlPay', 'Dividend', 'CashBox', 'ONDeposit',
               'DomPay', 'Forex', 'Loan', 'TermDep', 'CreditCard', 'DebitCard']:
        added += gencusttxns(5000004, 'Retail', 'Current', dt, tp, 5, 10, .8, .7, 10, 30)
pt("Added + " + str(added))
tx_count += added

pt("Total Customers: " + str(cid))
pt("Average Transactions: " + str(tx_count / cid))
pt("Total Transactions: " + str(tx_count))

csv_output_file.close()
pt("Generate Retail Transactions finished")

# Customers
# 0 - LowVolHighVal
# 1 - HiVolLowVal
# 2 - HiVolHiVal
# 3 - Multi Account
# 4 - MultiProduct
# CIB from retail to the below in December
# 10 - LowVolHighVal
# 11 - HiVolLowVal
# 12 - HiVolHiVal
# called retail but really
# 5...0 - LowVolHighVal
# 5...1 - HiVolLowVal
# 5...2 - HiVolHiVal
# 5...3 - Multi Account
# 5...4 - MultiProduct

# stats
# Permutations: 68981249
# 2016-05-27T22:36:00.800644 start
# 2016-05-27T22:47:45.506679 end
