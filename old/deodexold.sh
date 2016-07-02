baksmali -x $1.odex -c framework/core.jar:framework/ext.jar:framework/framework.jar:framework/services.jar:framework/android.policy.jar:framework/javax.obex.jar:framework/core-junit.jar:framework/filterfw.jar:framework/ime.jar:framework/input.jar:framework/monkey.jar:framework/pm.jar:framework/svc.jar:framework/am.jar:framework/android.test.runner.jar:framework/apache-xml.jar:framework/bmgr.jar:framework/bouncycastle.jar:framework/bu.jar:framework/com.android.location.provider.jar:framework/com.google.android.maps.jar;


smali out -o classes.dex;

jar -uf $1.jar classes.dex;
