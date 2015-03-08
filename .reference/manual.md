http://www.spasvo.com/news/html/2015120133414.html

金融数据一直是数据分析的重要数据来源，要做金融数据分析一定要有一个金融数据库，这篇博文就来教大家如何在自己的PC上建立一个简易金融数据库。
　　“工欲善其事，必先利其器”，建立数据库首先要有一个数据库软件，这里选择的是行业翘楚Oracle。幸运的是，Oracle学微软的那一套，推出了一个免费但功能有限的Oracle Express版本，虽然是功能有限但对基本的数据库操作足够了。为了更容易的操纵数据库Oracle SQL Developer也是少不了的，读者可以根据网站的介绍下载安装这两款软件，这里不再赘述。
　　“水有源，树有根”，没有数据源的数据库只是一个空的容器。这里把沪深两市的股票交易数据作为数据源，下面介绍如何获得这些数据。
　　第一步，获得股票代码。交易所网站是获得股票代码最可靠的来源，这里给出网址，深交所：http://www.szse.cn/main/marketdata/jypz/colist/；上交所：http://www.sse.com.cn/assortment/stock/list/name/。读者可以将这些代码分别复制保存在两个文件内，这里不再赘述。
　　第二步，寻找网络数据源。有些大型网站提供股票数据的下载服务，比如163。这里举一个例子，在163官网的股票板块查询浦发银行（600000），可以顺藤摸瓜找到浦发银行的历史交易数据，点击旁边的“下载数据”按键就可以下载数据了，数据以csv表格的形式存储。
　　第三步，自动化下载数据，这也是最复杂的一步。沪深两市的可交易股票有几千只，这些股票的数据完全由人工点击网页下载是不现实的，需要实现自动化下载。这里演示如何用R语言实现数据自动下载。在第二步点击“下载数据”按键下载数据的过程中可以得到下载数据的网址，这个网址是实现自动化下载的关键。打开第二步中的网页下载数据，如果使用的是360浏览器，在下载工具中可以得到下载链接，如下图，

　　如果使用的是火狐浏览器，可以在下载管理器中找到下载的文件，右键“复制下载链接”，如下图，

　　获得了下载链接后，下面分析一下链接的组成。刚才获得的链接是：http://quotes.money.163.com/service/chddata.html?code=0600000&start=19991110&end=20141231&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;
　　CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP，关键字一目了然，600000是股票代码；如果下载一个深市的股票可以发现，股票代码前的0表示沪市，1表示深市；19991110表示开始日期（下载时可以选择是上市日还是发行日，不过这里推荐用上市日），20141231表示截止日期；剩下的都是具体的数据项目。
　　新的问题来了，截止日期可以统一确定，上市日期却不能，必须分别获取股票的上市日期。来到网页http://quotes.money.163.com/trade/lsjysj_600000.html#01b07，这是查询数据前的状态，右键“查看网页源代码”，搜索一下“上市日”，可以发现“上市日”前面有一段代码“value="1999-11-10"”，这就是上市日。

　　根据网页的特征，可以用R语言自动化的分析网页内容，获得上市日数据，代码如下，

# jk註: 新地址 http://quotes.money.163.com/f10/gszl_600000.html
#下载股票上市日期
#download the listingdate of one security
library(RCurl)
SH <- readLines("SH.txt")#获取证券代码列表
listing.date <- vector(length = length(SH))
url.date1 <- "http://quotes.money.163.com/trade/lsjysj_"
url.date2 <- ".html#01b07"
for (i in 1:length(SH))
{
#解析网页，得到listingdate
cat(i，' ')
url.date <- paste(url.date1， SH[i]， url.date2， sep="")
xx <- getURL(url.date)
posi <- regexpr("上市日"，xx)
listing.date[i] <- substring(xx，posi[1]-13，posi[1]-4)
}
listing.date.tab <- data.frame(code=SH，listingdate=listing.date，stringsAsFactors=FALSE)
#输出
write.table(listing.date.tab，file="xxx.txt"，sep="	"，quote=FALSE，row.name=FALSE)
　　把下载好的数据按照市场分开，分别保存到txt文件即可，这里不再赘述。保存好的数据要稍微处理一下，日期的格式调整为yyyymmdd，write.table会把数据框的“列名”打印出来，列名也是要去掉的。
　　有了股票代码和上市日期数据就可以自动化下载数据了，最好深市沪市分开进行，存在不同的文件夹下，R代码如下，
#下载股票数据
library(RCurl)
#http://quotes.money.163.com/service/chddata.html?code=0600030&start=20030106&end=20140920&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP
url1    <- "http://quotes.money.163.com/service/chddata.html?code="
market  <- "1" # 1:深市，0:沪市
code    <- "000003"
url2    <- "&start="
start   <- "19900101"
url3    <- "&end="
end     <- "20140920"
url4    <- "&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP"
#文件的存放路径
file.path   <- "F:/download/SS/"
#股票代码+发行日期，格式：CODE制表符yyyymmdd
security <- readLines("SS.txt")
code <- vector(length = length(security))
listingdate <- vector(length = length(security))
security.tab <- data.frame(code， listingdate， stringsAsFactors=FALSE)
for (i in 1 : length(security))
{
security.tab[i，] = strsplit(security[i]，"	")
}
for (i in 1 : dim(security.tab)[1])
{
code <- security.tab$code[i]
start <- security.tab$listingdate[i]
cat(i，"	---"，code，" ")
url <- paste(url1，market，code，url2，start，url3，end，url4，sep="")
file <- paste(file.path，code，".csv"，sep="")
download.file(url，destfile=file， method="auto"，quiet=T)
}

　　上一段代码把股票数据下载到指定的文件夹，不过数据是以个股为单位独立的存储在csv文件中的，文件名即是股票代码。成百上千的csv文件不容易导入数据库，需要把这些文件拼接成几个大文件。
　　“百川汇流”，导入数据库。在正式导入数据库之前需要把几千个csv文件拼接成几个大型文件。为了提高逼格（真实的原因是建立数据库的时候本人还不会Python），这里用C++完成拼接文件的工作，其实有Python基础的读者也可以用Python来完成。文件拼接的C++程序如下，

#include <vector>
#include <fstream>
#include <string>
int main(void)
{
//处理股票数据
const int N = 1000;
ifstream fin;
vector<string> file_list，ff;
char  x[N];
string ss;
//获取要处理的文件列表
fin.open("fff.txt");
while (!fin.eof())
{
fin.getline(x， N， ' ');
ss.assign(x);
if (ss.size() > 0)
{
file_list.push_back(ss);
}
}
fin.close();
//cout<<file_list.size()<<endl;
ofstream fout， fout0，fout1，fout2，fout3，fout4，fout5;
string obj_file("x.csv")，path1("F:/download/obj/")，path2("F:/download/outh/");
for (int i = 0; i < file_list.size(); ++i)
{
cout<<i+1<<"	"<<file_list[i]<<endl;
int f_num = i / 500;
obj_file[0] = '0'+f_num;
fout.open(path2+obj_file，ofstream::out | ofstream::app);
fin.open(path1+file_list[i]);
bool first = true;
while (!fin.eof())
{
fin.getline(x， N， ' ');
ss.assign(x);
if (ss.size() > 0 && !first)
{
//1到1004为沪市
if (i+1<=1004)
{
ss="SH，"+ss;
}
else
{
ss="SS，"+ss;
}
ss.erase(7，1);
ss.erase(9，1);
ss.erase(12，1);
fout<<ss;
}
first = false;
}
fin.close();
fout.close();
}
}
　　需要解释一下，第一步获取要处理的文件的文件名列表，前半部分为沪市，后半部分为深市，列表存放在fff.txt文件（获取文件名列表可以用R中的dir函数）。第二步把所有文件转移到同一个文件夹下，运行C++程序处理文件，将文件归并到6个文件中。拼接的同时，在数据中增加了“市场”字段，SH表示沪市，SS表示深市。数据的日期格式因该是yyyymmdd，C++代码中已经通过ss.erase()调整过了。
　　文件拼接完成之后，按照数据的存储形式在Oracle中建立相应的“表”，在用SQL Developer将拼接好的csv文件中的数据导入Oracle就可以了，这完全是数据库操作，不再赘述。
　　做完上面几步就完成了股票数据库的建立，胜利收官。同理，举一反三地可以建立股票指数数据库。下面讲一下注意事项：
　　1.在数据下载的时候可能遇到打不开下载链接的情况，这时候R程序会报错并停止，这时候需要人工的跳过这个链接，重新运行程序，直接进入下一步的循环，所以下载的时候人工监控是少不了的。
　　2.建议用最新版的R运行程序，之前的版本在下载文件时存在内存溢出的现象，在下载几百个文件之后会因为内存不足而强行终止运行。
　　3.在数据导入数据库之后建议人工检验一下每一个字段，把存在空值的行删掉。
　　最后借助RODBC包把Oracle和R连接起来，给出一个数据分析的例子，计算一下浦发银行600000和上证指数000001之间的线性关系，R代码如下，
rm(list=ls())
library(RODBC)
channel <- odbcConnect(dsn="***"，uid="***"，pwd="***")
sql1 <- "SELECT dates， close， pre_close FROM idx
where
dates in
(
SELECT dates FROM idx where code='000001'
INTERSECT
SELECT dates FROM security where code='600000'
and
close > 0
and
dates >= to_date('20100101'， 'yyyymmdd')
)
and
code = '000001'
order by dates asc"
sql2 <- "SELECT dates， close， pre_close FROM security
where
dates in
(
SELECT dates FROM idx where code='000001'
INTERSECT
SELECT dates FROM security where code='600000'
and
close > 0
and
dates >= to_date('20100101'， 'yyyymmdd')
)
and
code = '600000'
order by dates asc"
i000001 <- sqlQuery(channel， sql1)
head(i000001)
s600000 <- sqlQuery(channel， sql2)
head(s600000)
t <- s600000$DATES
s <- log(s600000$CLOSE) - log(s600000$PRE_CLOSE)
i <- log(i000001$CLOSE) - log(i000001$PRE_CLOSE)
plot(i， s， pch = 20， xlab="000001"， ylab="600000")
capm.lm <- lm(s~i)
abline(coef = capm.lm$coe， co="red"， lwd=2)
