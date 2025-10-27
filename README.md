
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

<!-- GAMBAR -->
<img
  src="https://github.com/user-attachments/assets/8351b7b4-d757-4775-9ab3-7e278909ae74"
  alt="login "
  width="300"
/>


<img
  src= "https://github.com/user-attachments/assets/c3094cb3-c023-48c4-9109-81cf915251da"
  alt="signup"
  width="300"
/>


<img
  src= "https://github.com/user-attachments/assets/2adac72e-64cf-4942-936e-f0abd69285d4"
  alt="Home"
  width="300"
/>

<img
  src= "https://github.com/user-attachments/assets/d24a6ccd-aa69-4ca5-9c63-0923ed82dd1f"
  alt="statistic"
  width="300"
/>

<img
  src= "https://github.com/user-attachments/assets/3925b5b3-8a72-41e9-83dd-2e717f2fea60"
  alt="Export"
  width="300"
/>

<img
  src= "https://github.com/user-attachments/assets/a4314d7c-5410-4633-a90d-c5916f5c1ade"
  alt="API pesan"
  width="300"
/>






