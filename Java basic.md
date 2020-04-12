## 1 HashMap

1. HashMap是由数组和链表组成到数据结构, Java8之后新增了红黑树, 当一个链表的>=8的时候会将链表转化为红黑树, 低于7的时候又转换回来

   ```java
   if (binCount >= TREEIFY_THRESHOLD - 1) // TREEIFY_THRESHOLD 默认值为8
                               treeifyBin(tab, hash); // treeify意思就是树化
   ```

2. 通过hash函数去获取到key的hash值, 这个hash值就是其在数组中的位置

   ```java
   p = tab[i = (n - 1) & hash]
   ```

3. 某些情况下, 两个不同到key会得到一个相同到hash值, 这个时候就形成了一个链表, 每一个node中都存储了当前node到key, value, hash值以及下一个node. Java8之前是头插入, 之后变成尾插入

4. Hash公式为 `index = Hash(key) & (length - 1) `, 需要和数组当前长度进行位运算, 得到的结果和`Hash(key) % (length - 1) `相同, 但是位运算效率更高

5. 当长度>负载因子(LoadFactor)*当前总长度到时候, 就会进行扩容(resize), 在resize到时候会将旧的数组中到值重新hash到新得数组中去

6. 头插入式导致环形链表

   ​	在进行resize到时候会将原来到链表倒叙插入到新到数组中(如果hash之后仍得到相同到index), **当两个线程同时进行resize到时候, 线程1先完成一整个链表到插入到新到数组后, 线程2完成将原来到旧到head插入到新到head中**, 就会形成环形链表

   ​	sample:

   ​	before:		A -> B

   ​	after: 		 A -> B -> A

7. 头插入到问题就在于会在扩容转移到时候修改了链表到引用顺序, 从而导致其在多线程的情况下可能出现环形链表, Java8之后采用了尾插入到方式进行链表的添加, 就避免了扩容转移之后引用顺序的改变, 从而避免了环形链表到出现

8. HashMap的get和put是没有加同步锁的, 因此是无法保证线程安全到

9. 默认大小是1<<4 即16, 使用位运算是为了性能更高, 上面到hash函数中使用位运算也是一样到道理

10. 默认大写为16或者其他2到幂是为了使得length-1到所有二进制始位都为1, 这样Hash函数得到的结果就是对key进行hash得到的最后几位数, 只要传入到hashcode是均匀分布到, 那么Hash函数得到的到值也会是均匀分布到, 16应该是一个经验值, 其他2的幂当然也是可以的

11. 重写equals方法时必须要重写hashCode方法, 以HashMap为例, equals和hashCode都是继承于Object类, 此时的equals方法对比的是两个对象的值或内存地址, 我们对两个new出来的对象使用equals方法比较必然得到false, 我们通过重写equals方法去比较我们需要比较的属性后, 使得equals可以返回true了, 但是此时将这两个相同的对象作为key存入HashMap的时候, 会发现两个key被存入到两个不同的位置了, 这是因为HashMap是通过调用key对象的hashCode方法再与长度进行位求与(&)得到其对应的index值, 而未重写hashCode的时候调用的是Object的hashCode方法, 两个分别new出来的对象自然得到了两个不同的hashCode值, 为了使HashMap将这两个对象识别为相同的key, 我们就需要重写该对象的hashCode方法以保证这两个对象能得到相同的hashCode值而得到相同的index. HashSet同理

12. HashMap没有看到对对象或者方法加锁, 不是线程安全的, 可能出现
    1. 两个线程同时put导致值丢失, 两个线程同时将值插入同一个链表的时候
    2. get为null, 一个线程在get, 另外一个在resize导致第一个线程拿到的table变成空的了

13. HashMap和TreeMap的区别, 存储方式不一样导致查找效率不一样, 都用到了红黑树, 但是TreeMap没有hash存到数组, 而是所有值都存到了树中, TreeMap的作用是key是有序的, 而hashmap的key是无序的, 但是hashmap更适合插入, 删除和查找, 如果需要有序地遍历map, 那么使用TreeMap, 其他时候用hashmap就可以

## 2. 二分查找树(Binary Search Tree)&AVL树

1. 二分查找树即将比该节点小的值插入到左边, 大的值插入到右边, 树高为logn~n, 退化为链表的时候高度为n, 查找的时间复杂度为O(logn~n)

2. AVL树和红黑树都是平衡二叉树(Balanced Binary Tree), 为了解决二分查找树会退化成链表的问题, 实际中很少使用AVL树, 因为其效率相对红黑树低很多

3. 平衡二叉树的定义为其根的左右子树的高度差的绝对值不能超过1, 同时它的左右子树也都是平衡二叉树(即递归地查看左右子树的左右子树高度)

4. AVL树实现原理: 在插入一个叶节点后向上查看所有的父节点是否为平衡二叉树直到根节点, 如果遇到非平衡二叉树节点, 则对该节点进行左旋(LL), 右旋(RR), 左右旋(LR)或右左旋(RL), 该部分可稍作理解即可, 重点还是看红黑树, 下面是进行检查和旋转的伪代码可作参考

   ![rotate_left](https://img-blog.csdn.net/20180722220546910)

   ![rotate_right](https://img-blog.csdn.net/20180722222413303)

   *上图出自 https://blog.csdn.net/qq_37934101/article/details/81160254*

   ```python
   def checkBalanced(node):
       while node is not null:
           left = node.left
           right = node.right
           rootBalance = left.height - right.height
           # 如果绝对值大于1则表示以该点为root的二叉树不平衡, 大于0需要RR或LR, 小于0需要LL或RL
           if rootBalance == 2:
               leftBalance = left.left.height - left.right.height
               # 若右孙子树更高, 则需要左右旋(LR), 先左旋将其高出的节点归到左边再进行右旋
               if leftBalance < 0:
                   leftRotate(left)
               rightRotate(node)
           # LL或RL
           if rootBalance == -2:
               rightBalance = right.left.height - right.right.height
               # 和上面同理
               if leftBalance > 0:
                   rightRotate(left)
               leftRotate(node)
           node = node.parent
   
   # 下面是如何左旋或右旋的伪代码, 左旋是将当前节点的右节点调整到当前位置, 将当前节点挂到右节点的左边, 将右节点的左节点挂到当前节点的右边, 右旋同理
   def rotate(node, leftOrRight):
       parent = node.parent
   
       if leftOrRight is left:
           newNode = node.right
           newRight = newNode.left
           parent = node.parent
   
           node.right = newRight
           node.parent = newNode
           newNode.left = node
           newNode.parent = parent
   
       if leftOrRight is right:
           newNode = node.left
           newLeft = newNode.right
   
           node.left = newLeft
           node.parent = newNode
           newNode.left = node
           newNode.parent = parent
   
       if parent.left is node:
           parent.left = newNode
       else:
           parent.right = newNode
   
   ```
   删除节点的时候, 若左右节点都不为空, 则找到比当前节点大的最小节点来代替当前节点, 再进行调整. 若左右有空的 ,则直接拿不为空的节点插入到当前节点, 再向上检查是否平衡

## 3. 红黑树(Red&Black Tree)

红黑树(重点, 先理解AVL树有助于理解红黑树), 规则如下

1. **每个节点要么红色要么黑色**
2. **根节点一定是黑色**
3. **不能有连续的两个红色**
4. **叶子节点(NIL)一定是黑色(默认每个有值的叶子节点都会有两个NIL叶子节点, 但有时候会省略NIL节点不画)**
5. **从根节点到任意一叶子节点经过的黑色节点数量是相同的**(最重要规则)

通过以上规则, 在插入和删除的时候对树进行调整, 使得红黑树的查询效率始终保持在O(log n), 我们通过红黑树的插入和删除操作来理解以上规则

*Tips:*

1. *所有新插入的节点默认都是红色, 否则可能出现整颗树都是黑色却满足其定义, 使得整个数据结构无意义*

2. *红黑树并非严格的平衡二叉树, 但是通过数学证明, 其最坏情况下的高度不会超过2log(n), 所以其时间查询*的时间复杂度始终为O(log n)*

*以下图片出自 https://www.jianshu.com/p/e136ec79235c, 可直接去该博客阅读更为详细, 我的内容偏总结*

### 3.1 插入

#### 1. 空树

直接作为根节点, 并将颜色改为黑色

#### 2. key已存在

查找到当前key, 再替换其值

#### 3.  插入节点的父节点为黑色

直接插入, 因为不会影响黑色节点的层高, 也不会影响其他规则

#### 4. 插入节点的父节点为红色

此时需要再分3种情况进行考虑, 但是情况2和3是镜像的情况, 所以理解一个即可理解另外一个

##### 4.1 叔叔节点存在并为红色

1. 将父节点和叔叔节点设为黑色
2. 将祖父节点设为红色
3. 将祖父节点设为当前插入节点进行调整(*即递归地自下而上进行调整, 对祖父节点重新考虑1~4中情况*)

##### 4.2 叔叔节点为黑色(NIL同样是黑色), 父节点是祖父的左子节点

1. 将父节点变为黑色. 祖父节点变为红色

2. 进行旋转

   *Tips: 此时又需要考虑插入节点是父节点的左节点还是右节点, 但此时我们可以参考AVL树的RR旋和LR, 左节点RR旋, 右节点LR旋, LR旋是为了将右节点调整到左边就变成一种情况了*

3. 若为右节点, 则先对父节点进行左旋, 再对祖父节点进行右旋, 若为左节点, 直接右旋

   *Tips: 在进行了第一步之后, 很明显祖父的左子的黑色层高不变而右子的黑色层高 -1了, 不符合规则5了, 此时进行右旋, 从而使得右子的黑色层高恢复*

##### 4.3 叔叔节点为黑色, 父节点是祖父的右子节点

很明显此情况和4.2互为镜像, 不再多言

![red-black tree insert](https://upload-images.jianshu.io/upload_images/2392382-fa2b78271263d2c8.png)

下面代码是从Java HashMap中拖出来的代码

```java
// X是插入的新的节点
static <K,V> TreeNode<K,V> balanceInsertion(TreeNode<K,V> root, TreeNode<K,V> x) {
    // x在插入后还未调整的时候一定是红色
    x.red = true;
    // 下面for循环没有设置退出条件仅初始化了一些变量, 只有return的时候退出
    for (TreeNode<K,V> xp, xpp, xppl, xppr;;) {
        // 情况1 -- xp是null表示插入节点为根节点, 直接返回x, 
        if ((xp = x.parent) == null) {
            x.red = false;
            return x;
        }
        // 情况3 -- 父节点为黑色或者祖父为空时, 不会破坏规则, 直接返回root, 但是如果祖父为空, 表示父节点为根节点, 那么父节点一定是黑色, 可能是为了更严谨吧 
        else if (!xp.red || (xpp = xp.parent) == null)
            return root;
        // 情况4
        if (xp == (xppl = xpp.left)) {
            // 情况4.1 -- 将父亲和叔叔都变为黑色, 祖父变为红色, 将祖父设为插入节点, 进行下一个循环
            if ((xppr = xpp.right) != null && xppr.red) {
                xppr.red = false;
                xp.red = false;
                xpp.red = true;
                x = xpp;
            }
            // 情况4.2 -- 父亲为红色, 叔叔为黑色, 此时需要进行旋转
            else {
                // 情况4.2.2 -- 插入节点和父节点不在同一边, 需要先将插入节点旋转到父节点一边, 之后就变成了情况4.2.1了
                if (x == xp.right) {
                    // 左旋和右旋的代码可以参考AVL树部分的代码, 或者去查看hashmap的源码原理都一致
                    root = rotateLeft(root, x = xp);
                    xpp = (xp = x.parent) == null ? null : xp.parent;
                }
                // 情况4.2.1 -- 此时x在上一步变成了父节点了, 这里的xp也变成了祖父节点了, 通过上面的判断, 这里的祖父节点也是不可能为null的应该, 或许还是为了严谨吧
                if (xp != null) {
                    xp.red = false;
                    if (xpp != null) {
                        xpp.red = true;
                        root = rotateRight(root, xpp);
                    }
                }
            }
        }
        // 下面就是父节点为右子节点的情况了, 和上面的代码除了left和right, 其他都一样, 就不再赘述
        else {
```



### 3.2 删除

删除相对于插入更为复杂, 首先分三种情况

1. 删除节点为无子节点, 直接删除

2. 删除节点有一个子节点, 则用那个子节点来替换删除节点

3. 删除节点有两个子节点, 则用后继节点来替换删除节点

   *Tips: 后继节点表示比当前节点大的最小节点, 即右子树的最左节点. 用前继节点也是可以的, 不过一般习惯用后继节点*

此时我们对这三种情况进行抽象, 可以得到一个结论: **将替换节点视作删除节点, 删除节点总是无子节点的树末节点**

​	*Tips: 如何得到这个结论请参考  https://www.jianshu.com/p/e136ec79235c*

以下是将仅考虑替换节点的删除时所有的情况

![red-black tree delete](https://upload-images.jianshu.io/upload_images/2392382-edaf96e55f08c198.png?imageMogr2/auto-orient/strip|imageView2/2/format/webp)

下面代码是从Java HashMap中拖出来的代码, 此时已经用上述思路找到了替换节点了, 之后先将整棵树平衡, 再将该节点返回回去从它的父节点处将其删除(即将指向设为null), 关于如何找到替换节点可以去参考hashmap的源码, 原理就是上述讨论

```java
static <K,V> TreeNode<K,V> balanceDeletion(TreeNode<K,V> root, TreeNode<K,V> x) {
    for (TreeNode<K,V> xp, xpl, xpr;;) {
        // 如果为根节点, 直接返回
        if (x == null || x == root)
            return root;
        else if ((xp = x.parent) == null) {
            x.red = false;
            return x;
        }
        // 情况1
        else if (x.red) {
            x.red = false;
            return root;
        }
        // 情况2.1
        else if ((xpl = xp.left) == x) {
            // 情况2.1.1 -- 兄弟为红色, 兄弟的子节点一定是黑色(包括NIL), 左旋后借来兄弟一个黑色节点, 此时就转换为了2.1.2情况继续往下走, 此时xpr变成了刚才借来的那个节点了(即兄弟节点的左子)
            if ((xpr = xp.right) != null && xpr.red) {
                xpr.red = false;
                xp.red = true;
                root = rotateLeft(root, xp);
                xpr = (xp = x.parent) == null ? null : xp.right;
            }
            // 情况2.1.2 -- 兄弟是黑色, 打兄弟儿子的主意 
            // 情况2.1.2.3 -- xpr为null就表示兄弟节点的子节点全是黑色, 此时就无法在当前子树进行平衡了, 就把兄弟改为红色, 将删除节点设为父节点, 进入下一个循环去考虑(兄弟改为红色就相当于让兄弟也不平衡了)
            if (xpr == null)
                x = xp;
            else {
                TreeNode<K,V> sl = xpr.left, sr = xpr.right;
                // 同样情况2.1.2.3 -- 兄弟的子节点全是黑色或null
                if ((sr == null || !sr.red) &&
                    (sl == null || !sl.red)) {
                    xpr.red = true;
                    x = xp;
                }
                else {
                    // 情况2.1.2.2 -- 右子黑色, 左子红色, 此时先进行右旋将情况转为2.1.2.1, 即先把黑色旋到右边去, 等会2.1.2.1好变回黑色补充右边的黑色
                    if (sr == null || !sr.red) {
                        if (sl != null)
                            sl.red = false;
                        xpr.red = true;
                        root = rotateRight(root, xpr);
                        xpr = (xp = x.parent) == null ?
                            null : xp.right;
                    }
                    // 情况2.1.1.1 -- 第一个if这里先将刚才旋出来兄弟改为父节点一样的颜色, 再把刚刚旋到右边去的红色儿子转为黑色
                    if (xpr != null) {
                        xpr.red = (xp == null) ? false : xp.red;
                        if ((sr = xpr.right) != null)
                            sr.red = false;
                    }
                    // 下面开始变形了, 把父节点变为黑色, 再左旋, 左边的黑色加一补充上了
                    if (xp != null) {
                        xp.red = false;
                        root = rotateLeft(root, xp);
                    }
                    // 这棵子树平衡回之前的黑色层高了, 整棵树肯定也平衡了, 直接返回了
                    x = root;
                }
            }
        }
        // 下面就是情况2.2的情况了, 和2.1基本相同除了左右
        else {
```

总结: 先看兄弟能不能帮忙, 兄弟帮不了就把兄弟搞没了(变红), 然后让交给父亲处理, 父亲又去找他的兄弟或父亲, 走到最后, 要么借来一个黑色, 要么一起没一个(变红一个), 如下就是大家一起变红一个, 没有旋转

![](https://upload-images.jianshu.io/upload_images/2392382-b037e4c29cbffc4d.png?imageMogr2/auto-orient/strip|imageView2/2/format/webp)





**红黑树和AVL树对比, 红黑树没有追求绝对的平衡, 使得其每次插入的时候最多旋转3次即可平衡, 而AVL树每次插入需要的旋转次数无法预测**	

*这一节的图片均来自 https://www.jianshu.com/p/e136ec79235c*



## 4. 锁

### 4.1 悲观锁和乐观锁

悲观锁的概念:

​	对于同一个数据的并发操作, 悲观锁认为自己在使用数据的时候一定有别的线程来修改数据, 因此在获取数据的时候会先加锁, 确保数据不会被别的线程修改. Java中, synchronized关键字和Lock的实现类都是悲观锁.

乐观锁的概念:

​	乐观锁认为自己在使用数据时不会有别的线程修改数据, 所以不会添加锁, 只是在更新数据的时候去判断之前有没有别的线程更新了这个数据. 如果这个数据没有被更新, 当前线程将自己修改的数据成功写入, 如果数据已经被其他线程更新, 则根据不同的实现方式执行不同的操作

​	乐观锁的常用实现是CAS算法, 全称Compare And Swap算法. 3个值V, A, B. V为内存中的值, A为需要对比的值, B为新的值, 当需要把V更新为B的时候, 先对比V和A的值, 如果不相等, 将V的值赋给A再进行对比, 直到相等后将B的值更新到V. 比较和更新作为一个原子操作



悲观锁适用于写操作多的场景保证数据正确, 乐观锁适用于读操作多的场景提高效率

### 4.2 互斥锁

在访问共享资源之前对进行加锁操作,在访问完成之后进行解锁操作. 加锁后, 任何其他试图再次加锁的线程会被阻塞, 直到当前进程解锁.

如果解锁时有一个以上的线程阻塞, 那么所有该锁上的线程都被编程就绪状态, 第一个变为就绪状态的线程又执行加锁操作, 那么其他的线程又会进入等待. 在这种方式下, 只有一个线程能够访问被互斥锁保护的资源

### 4.3 volatile

- 保证了不同线程对这个变量进行操作时的可见性，即一个线程修改了某个变量的值，这新值对其他线程来说是立即可见的。（实现**可见性**）

- 禁止进行指令重排序。（实现**有序性**）

- volatile 只能保证对单次读/写的原子性。i++ 这种操作不能保证**原子性**。

  用了之后安全

### 4.4 自旋锁

自旋锁是当该锁有持有者的时候就会不停地循环去获得锁, 如果直到最大尝试次数的时候仍然没有获得锁则改为阻塞锁获取直到获得锁

自旋锁适用于锁使用者保持锁时间比较短的情况, 在这种情况下自旋锁的效率会远高于互斥锁

## 5 ConcurrentHashMap

Collections.synchronizedMap(Map) 和HashTable都是线程安全的, 但是实现方式都是给每个方法加上每个方法加上synchronized关键字, 效率较低, 也可使用Collections.synchronizedMap(Map, mutex), 自行传入一个对象作为互斥锁, 不传就用this作为互斥所.

下面就是Collections.synchronizedMap的实现方式

![](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpyhVLAW08sszrgEKUamuEKRgG8CTU8Uj4k0djWqQiaiayXO7H3WTTUN0v0jegVsj8fxBcCcIl4XAmqg/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

接下来看ConcurrentHashMap有何不同

### 5.1 fail-fast和fail-safe

**fail-fast**:

​	当对一个集合使用interator对一个集合进行遍历的时候, 若这个集合被修改, 就会抛出Concurrent Modification Exception

​	原理: 一个变量modCount, 当对集合进行操作的时候, 就会修改这个变量的值, 而在进行遍历的时候, 首先会将modCount的值赋给expectedModCount, 然后每次循环都会去检查modCount是否等于expectedModCount, 如果不相等, 就抛出上述异常 *(Iterator中的remove()方法可以在遍历的时候使用, 他在remove之后会去修改expectedModCount的值, 所以不会抛出异常)*

​	Java.util下面的集合如HashMap和ArrayList等都实现了fail-fast(但是HashTable是用的fail-safe, 因为其支持多线程), 是一种安全机制, 但是这个机制的缺陷在于有可能修改后的modCount的值和之前的值相等, 因此还是不能依赖于这个机制进行并发编程, 只建议用于检测并发修改的bug

**fail-safe**:

​	在遍历的时候会将集合中的内容copy出多一份, 然后在copy出来的那份上进行遍历, 缺点就是没有可能无法拿到最新的数据, 同时消耗更多内存. Java.util.concurrent包下面的集合使用的都是这种方式

### 5.2 ConcurrentHashMap不能用null作为key和value

官方解释是说如果用null作为key或value, 你就无法通过get()来判断究竟是没有这个key还是key或value为null了, 特别是在ConcurrentHashMap中使用了fail-safe, 使得你遍历可能都不是最新的数据, 更导致了混淆的可能, 因此禁止了在ConcurrentHashMap中使用null, 而在HashMap中我们可以使用containKey()来判断, 而在ConcurrentHashMap中不能使用containKey()来判断null, 因为可能判断的是另外一个集合了

### 5.3 put和get流程

不论是1.7还是1.8都采用了分段锁的技术, 使得其效率相较于HashTable和synchronizedMap都要高

### 5.3.1 Java1.7

1.7中底层数据结构是segment[] -> HashEntry[] -> HashEntry链表, segment继承了ReentrantLock

put:

1. 通过hash找到在segment数组中找到对应segment, 通过自旋获得segment的锁, 如果尝试次数达到最大尝试次数则进入阻塞直到获取到锁(自旋锁)
2. 获得锁之后, 再hash找到对应HashEntry[]中的位置, 如果为空直接插入
3. 如果插入的链表的长度超过了threshold, 则对该node进行重新hash

get:

​	get的逻辑相对简单, 不会上锁, 直接通过两次hash找到对应segment的对应HashEntry, 再遍历该链表, 找到对应的key即可, 因为value是用volatile关键字修饰的, 保证了内存可见性, 所以每次获取时都是最新值

因为锁是加在segment上的, 所以理论上来说, 就多少个segment, 就支持多少的并发

但是和1.7的HashMap有一样的问题, 就是需要遍历链表, 如果链表长度很长, 则效率很差. 1.8又做了很多改进