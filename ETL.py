import mysql.connector
import pandas as pd

config = {
  'user': 'root',
  'password': '1234',
  'host': '127.0.0.1',
  'database': 'gbc_superstore',
  'raise_on_warnings': True
}

con = mysql.connector.connect(**config)
cursor = con.cursor()


managers_df = pd.read_csv('Managers.csv')

# first we create And set the relationship 
# between Manager and Region Table

for i in range(len(managers_df)):
    query = """ SELECT Manager_ID, Name FROM RegionalManager WHERE 
        Name = %s
    """
    cursor.execute(query, (managers_df.iloc[i]['Regional Manager'],))
    if len(cursor.fetchall()):
        continue

    sql = """INSERT INTO  RegionalManager (Name) Values(%s)"""
    cursor.execute(sql, (managers_df.iloc[i]['Regional Manager'],))

    manager_id = cursor.lastrowid
    sql = """INSERT INTO  Region (Name, Manager_ID) Values(%s, %s)"""
    cursor.execute(sql, (managers_df.iloc[i]['Region'], manager_id))

    con.commit()



orders_df = pd.read_csv('Orders.csv')

counter = 0

# for i in range(1000):
for i in range(len(orders_df)):
    # insert into customer table
    query = """ SELECT Customer_ID FROM Customers WHERE 
        Customer_ID = %s
    """
    cursor.execute(query, (orders_df.iloc[i]['Customer ID'],))
    res = cursor.fetchall()
    if len(res):
        cus_id = res[0][0]
    else:
        sql = """ INSERT INTO  Customers (Customer_ID, FullName, Segment) 
                Values(%s, %s, %s) """
        
        data = (
            orders_df.iloc[i]['Customer ID'], 
            orders_df.iloc[i]['Customer Name'],
            orders_df.iloc[i]['Segment']
        )
        cursor.execute(sql, data)
        cus_id = orders_df.iloc[i]['Customer ID']
    

    # insert into category table
    query = """ SELECT Category_ID FROM Category WHERE 
        Category_Name = %s
    """
    cursor.execute(query, (orders_df.iloc[i]['Category'],))
    res = cursor.fetchall()
    if len(res):
        cat_id = res[0][0]
    else:
        sql = """INSERT INTO Category (Category_Name) Values(%s)"""
        cursor.execute(sql, (orders_df.iloc[i]['Category'],))
        cat_id = cursor.lastrowid
    
    # insert into sub-category table
    query = """ SELECT SubCategory_ID FROM SubCategory WHERE 
        Name = %s
    """
    cursor.execute(query, (orders_df.iloc[i]['Sub-Category'],))
    res = cursor.fetchall()
    if len(res):
        subCat_id = res[0][0]
    else:
        sql = """INSERT INTO SubCategory (Name, Category_ID) Values(%s, %s)"""
        cursor.execute(sql, (orders_df.iloc[i]['Sub-Category'], cat_id))
        subCat_id = cursor.lastrowid

    # insert into product table
    # Same product with different IDs
    # Same product with different names
    # query = """ SELECT Product_ID FROM Product WHERE 
    #     Product_ID = %s
    # """
    query = """ SELECT Product_ID FROM Products WHERE 
        Product_Name = %s OR Product_ID = %s
    """
    cursor.execute(
        query, 
        (orders_df.iloc[i]['Product Name'], orders_df.iloc[i]['Product ID'])
    )
    res = cursor.fetchall()
    if len(res):
        prod_id = res[0][0]
    else:
        sql = """INSERT INTO  Products (Product_ID, Product_Name, SubCategory_ID) 
                Values(%s, %s, %s)"""
        
        data = (
            orders_df.iloc[i]['Product ID'], orders_df.iloc[i]['Product Name'],
            subCat_id
        )
        cursor.execute(sql, data)
        prod_id = orders_df.iloc[i]['Product ID']


    # insert into Orders table
    query = """ SELECT Order_ID FROM Orders WHERE 
        Order_ID = %s
    """
    cursor.execute(query, (orders_df.iloc[i]['Order ID'],))
    res = cursor.fetchall()
    if len(res):
        order_id = res[0][0]
    else:
        # create shipping info
        sql = """INSERT INTO  ShippingInfo (ShipMode, City, State, Country, PostalCode) 
                Values(%s, %s, %s, %s, %s)"""
        
        # handle null postal code
        try:
            postal_code = int(orders_df.iloc[i]['Postal Code'])
        except Exception:
            postal_code = 0

        data = (
            orders_df.iloc[i]['Ship Mode'], orders_df.iloc[i]['City'],
            orders_df.iloc[i]['State'], orders_df.iloc[i]['Country'],
            postal_code
        )
        cursor.execute(sql, data)
        shipping_id = cursor.lastrowid

        # Get region ID
        query = """SELECT Region_ID FROM Region WHERE Name = %s"""
        cursor.execute(query, (orders_df.iloc[i]['Region'],))
        res = cursor.fetchall()
        reg_id = res[0][0]


        sql = """ INSERT INTO Orders (
            Order_ID, OrderDate, ShipDate, Customer_ID, Shipping_ID, Region_ID)
            Values(%s, %s, %s, %s, %s, %s)
        """
        
        data = (
            orders_df.iloc[i]['Order ID'], orders_df.iloc[i]['Order Date'], 
            orders_df.iloc[i]['Ship Date'], cus_id, shipping_id, reg_id
        )
        cursor.execute(sql, data)
        order_id = orders_df.iloc[i]['Order ID']


    # relate Order to Products
    sql = """ INSERT INTO  OrderDetails (
        Order_ID, Product_ID, Sales, Quantity, Discount, Profit) 
        Values(%s, %s, %s, %s, %s, %s)
    """
    data = (
        order_id, prod_id, float(orders_df.iloc[i]['Sales']), 
        int(orders_df.iloc[i]['Quantity']), float(orders_df.iloc[i]['Discount']),
        float(orders_df.iloc[i]['Profit'])
    )
    cursor.execute(sql, data)



# create returns table
returns_df = pd.read_csv('Returns.csv')
for i in range(len(returns_df)):
    # 1 - Yes, 0 - No
    # avoid duplicate entries
    query = """ SELECT * FROM Returned WHERE Order_ID = %s """
    cursor.execute(query, (returns_df.iloc[i]['Order ID'],))

    if not len(cursor.fetchall()):
        ret = int(str(returns_df.iloc[i]['Returned']).strip().lower() == 'yes')
        sql = """INSERT INTO  Returns (Returned, Order_ID) Values(%s, %s)"""
        cursor.execute(sql, (ret, returns_df.iloc[i]['Order ID']))


con.commit()
cursor.close()
con.close()
print('Done')