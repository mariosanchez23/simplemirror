# Super SIMPLE docker-compose with mirroring for versions 2019.2 and before.
This version is the same but with little changes that requires scripts to be modified to pass the password. 

## start the mirror (with password "SYS")
```
echo SYS >pwdA.txt
echo SYS >pwdB.txt
docker-compose up
```

## recreate the mirror
```
docker-compose down
rm -R iris?
rm pwd?.txt.done

```

## Notes

The installer.sh contains the password "SYS" as well as the echo commands from the exampel. If you prefer a different password you must change it also in the installer.sh
