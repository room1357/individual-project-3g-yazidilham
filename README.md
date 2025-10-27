
# AHMAD YAZID ILHAM

## 2341760156

#### 2_SIB_3G

## Acknowledgements
  Future<void> addDummyUsers() async {
    final sp = await SharedPreferences.getInstance();

    // 🔹 Dummy pertama
    final existing1 = sp.getString(_keyEmail);
    if (existing1 == null) {
      await sp.setString(_keyUid, 'dummy-001');
      await sp.setString(_keyEmail, 'budi@gmail.com');
      await sp.setString(_keyPassword, 'password123');
      await sp.setString(_keyUsername, 'budi');
      await sp.setString(_keyFullName, 'Budi Santoso');
      print('🌱 Dummy 1 dibuat: budi@gmail.com / password123');
    }

    // 🔹 Dummy kedua
    final existing2 = sp.getString(_keyEmail2);
    if (existing2 == null) {
      await sp.setString(_keyUid2, 'dummy-002');
      await sp.setString(_keyEmail2, 'siti@gmail.com');
      await sp.setString(_keyPassword2, 'rahasia456');
      await sp.setString(_keyUsername2, 'siti');
      await sp.setString(_keyFullName2, 'Siti Aminah');
      print('🌱 Dummy 2 dibuat: siti@gmail.com / rahasia456');
    }
  }

  ada 2 user dummy

  
## API Reference

#### Get all items

```http
  GET /api/items
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `api_key` | `string` | https://jsonplaceholder.typicode.com/|

#### Get item

```http
  GET https://jsonplaceholder.typicode.com/
```



## Demo APLIKASI

GAMBAR





