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

14. 线程不安全实例

    1. 1.7中的环形链表. 1线程变量指向B后挂起, 2线程转移完A->B后, 线程1继续执行将B->A, 就变成了B->A->A
    2. 数据丢失, 在数组位置为空的情况下没有使用CAS进行插入, 两个线程同时进行插入就会导致一个线程的数据丢失

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

- 保证了不同线程对这个变量进行操作时的可见性, 即一个线程修改了某个变量的值, 这新值对其他线程来说是立即可见的. （实现**可见性**）

- 禁止进行指令重排序. （实现**有序性**）

- volatile 只能保证对单次读/写的原子性. i++ 这种操作不能保证**原子性**. 

  用了之后安全

### 4.4 自旋锁

自旋锁是当该锁有持有者的时候就会不停地循环去获得锁, 如果直到最大尝试次数的时候仍然没有获得锁则改为阻塞锁获取直到获得锁

自旋锁适用于锁使用者保持锁时间比较短的情况, 在这种情况下自旋锁的效率会远高于互斥锁

### 4.5 synchronized以及锁升级

1. 修饰普通方法: 锁当前实例对象
2. 修饰静态方法: 锁当前class类对象
3. 修饰代码块: 锁synchronized后面括号里面的对象

锁升级(简单总结):

​	无锁->偏向锁->轻量级锁->重量级锁

​	当一个对象刚刚被new出来的时候是无锁, 第一个线程来一看没有锁, 就使用一次CAS将自己的thread id 放到mark word中,   之后相同线程过来查看是相同的thread id, 则不再加锁, 这时如果有另一线程前来竞争, 则升级为轻量级锁, 此时不断通过CAS自旋来竞争锁, 没有竞争到锁的线程一直自旋, 直到自旋次数达到限制或者竞争的线程数量超过CPU核心的一半, 则升级为重量级锁, 此时竞争线程全部进入waiting状态, 直到锁释放被唤醒 

### 4.6 ReentrantLock

ReentrantLock与synchronized都是独占锁, 相较于synchronized, ReentrantLock需要手动加锁和解锁, 操作更复杂, 但是灵活度高了很多, 同时ReentrantLock可以响应中断. 这些特点使得它适合于更为复杂的多线程场景

1. 公平锁与非公平锁

   `new ReentrantLock(true)`, 在创建锁对象的时候, 传入参数true, 获得的锁就是公平锁, 即哪个线程等待时间最长, 则那个线程先获得锁. 非公平锁就是创建的时候传入false或不传, 哪个线程运气好, 那个获得锁

2. 响应中断

   上锁时调用`lockInterruptibly()`, `catch(InterruptedException)`, 然后在线程调用`interrupt()`方法后, 就可以将该线程中断, 拿到的锁释放, 人为解决死锁

3. 限时等待

   上锁时使用`tryLock()`, `tryLock(long timeout,TimeUnit unit)`, `tryLock`会尝试去获得一次锁(非公平), 如果失败, 返回false, 此时线程可以去做其他事, 如果传入时间, 则会在指定时间去尝试获取锁(公平)

4. 使用condition实现线程间等待通知

   保证两个线程该休眠时休眠, 该工作时工作

   ```java
   public class MyBlockingQueue<E> {
       int size;//阻塞队列最大容量
       ReentrantLock lock = new ReentrantLock();
       LinkedList<E> list=new LinkedList<>();//队列底层实现
       Condition notFull = lock.newCondition();//队列满时的等待条件
       Condition notEmpty = lock.newCondition();//队列空时的等待条件
   
       public MyBlockingQueue(int size) {
           this.size = size;
       }
   
       public void enqueue(E e) throws InterruptedException {
           lock.lock();
           try {
               while (list.size() ==size)//队列已满,在notFull条件上等待
                   notFull.await();
               list.add(e);//入队:加入链表末尾
               System.out.println("入队：" +e);
               notEmpty.signal(); //通知在notEmpty条件上等待的线程
           } finally {
               lock.unlock();
           }
       }
   
       public E dequeue() throws InterruptedException {
           E e;
           lock.lock();
           try {
               while (list.size() == 0)//队列为空,在notEmpty条件上等待
                   notEmpty.await();
               e = list.removeFirst();//出队:移除链表首元素
               System.out.println("出队："+e);
               notFull.signal();//通知在notFull条件上等待的线程
               return e;
           } finally {
               lock.unlock();
           }
       }
   }
   ```

   *以上代码出自 [cnblogs]([https://www.cnblogs.com/takumicx/p/9338983.html#4-%E7%BB%93%E5%90%88condition%E5%AE%9E%E7%8E%B0%E7%AD%89%E5%BE%85%E9%80%9A%E7%9F%A5%E6%9C%BA%E5%88%B6](https://www.cnblogs.com/takumicx/p/9338983.html#4-结合condition实现等待通知机制))*

5. CountDownLatch和CyclicBarrier

   CountDownLatch是主线程阻塞, n个线程进行工作, 完成工作后调用countDown(), 当减到0后, 主线程继续

   CyclicBarrier是n个线程进行某项工作, 到达指定地点后阻塞, 直到所有线程都到达该地点, 所有线程一起继续

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

### 5.3.2 Java1.8

1.8中ConcurrentHashMap和HashMap的底层数据结构一样, 都是Node数组加链表, 红黑树的形式, ConcurrentHashMap在进行写入的时候做了一些额外的多线程安全的操作, 1.8中对synchronized关键字进行了优化, 所以ConcurrentHashMap中放弃了使用ReentrantLock改用synchronized

Put:

1. 判断key或value是否为空, 如果为空, 则抛出异常
2. 计算key的hash值
3. 判断是否需要初始化数组
4. 将key的hash值和数组长度进行hash再定位其在数组中的位置, 如果该位置是null, 则用CAS算法写入, 此时不加锁(CAS为乐观锁), 如果写入成功就break, 否则表示有其他线程更新了该值, 则又从判断数组是否为空开始判断
5. 判断当前位置是否在进行扩容, 如果是就调用`tab = helpTransfer(tab, f);`帮助其转移数据, 完成后又从数组是否为空开始判断
6. 如果上面3 4 5都不满足, 就对当前位置的node使用synchronized进行上锁并写入链表或者红黑树
7. 写入之后检查当前node的长度是否超过TREEIFY_THRESHOLD(8), 如果超过8, 再判断总的大小是否小于MIN_TREEIFY_CAPACITY(64), 如果不够64, 则进行扩容, 否则才将链表转为红黑树

Get:

​	get相对就简单多了, 首先hash找到对应数组上的位置, 如果就在root上, 则直接返回, 否则就按链表或二叉树的查找方法进行查找

## 6 List

ArrayList: 查询效率高因为其内存连续性, 插入和删除到效率可能很低

LinkedList: 插入和删除到效率很高

Vector: 数据结构和ArrayList一样, 只是每个方法加了synchronized关键字以保证其线程安全, 类似于HashMap和ConcurrentHashMap, 使用java.util.concurrent.CopyOnWriteArrayList效率会更高



ArrayList插入:

​	插入到时候都会检查capacity即数组长度, 若不够则进行扩容, 规则为`length+length>>1`(>>1表示位运算除以2的1次方), 下面说的情况中都会省略capacity检查

- 若调用add(E e), 则直接插入到数组末尾
- 若调用add(int index, E element), 则需要使用System.arraycopy将index后面到所有值向后移动一位

ArrayList删除:

​	删除的时候必须传入index, 因此删除之后必须将index后面的所有值向前移动一位

因此如果插入和删除一直在数组到尾部进行, 则其效率很高, 插入和删除的index越靠近头部, 效率越低



由上面可知ArrayList实现队列不合适, 不论是头部插入尾部删除还是尾部插入头部删除, 效率都很低

固定长度的数组(循环数组)可用来实现队列, 两个指针start和end, start指针进行处理, end指针进行插入, 当指针指到尾部后又从头上开始循环

## 复合操作下的线程安全

Vector, HashTable以及使用Collection下到synchronized获得一个线程安全到容器后, 我们在调用单个方法入put和add等到时候是线程安全的. 但是如果我们同时调用size和put方法就可能出问题, 在将size得到到结果在put中使用的时候, 就可能出问题, 即不能保证原子性, 这个时候, 需要将调用这两个方法的方法加锁. ConcurrentHashMap到put方法也是不能保证原子性安全到, 他提供了putIfAbsent方法可以给你来实现复合操作的安全, 以及CopyOnWrite系列的也能保证安全



### 7 TCP/IP
TCP/IP协议分为四层, **应用层 传输控制层 网络层 网络接口层**, 其中网络接口层可以划分为**链路层**和**物理层**

### 7.1 应用层

即应用程序对应一层, 每个应用选择一个应用层协议(e.g. HTTP HTTPS FTP)使用一个socket进行与互联网中的另一台计算机进行通信

### 7.2 传输控制层

在这一层中会选择两种协议进行传输分别是**TCP(Transmission Control Protocol)**和**UDP(User Datagram Protocol)**, 通常问的TCP即这里的TCP协议

#### TCP

是一种面向连接的、可靠的、基于字节流的通信协议, 数据传输前**三次握手**建立连接, 传输完成后**四次挥手**断开连接, 通过这种方式去尽可能保证连接的稳定性(不能保证绝对稳定)

- 三次握手

  1. client  -syn-> server // client发送一个SYN标志的包到server, client状态变为SYN-SEND

  2. client <-syc+ack- server // server收到后创建一个SYN和ACK标志的包发送给client, server状态变为SYN-RECV

  3. client -ack-> server // client收到server发的SYN+ACK包, 再创建一个ACK标志的包发送给server, client状态变为ESTABLISHED, 之后server收到client的ACK包, server状态也变为ESTABLISHED

     ![shake](https://upload-images.jianshu.io/upload_images/11362584-75c208edcfb986fc.jpeg?imageMogr2/auto-orient/strip|imageView2/2/w/438/format/webp)

  总结, 双方互相确认网络畅通后才创建资源(socket)

- 四次挥手

  1. clinet -fin-> server // client发送一个FIN标志的包给server, client状态变为FIN_WAIT_1
  
  2. client <-ack- server // server收到FIN包后, 发送一个ACK包给client表示知道需要断开了, 但是还需要一点准备时间, server状态变为CLOSE_WAIT
  
3. client <-fin- server // 经过一段时间后, server准备好了, 向client再发送一个FIN包, server状态变为LAST_ACK
  
  4. client -ack-> server // client收到FIN包后, 发送一个ACK包给server, client状态变为TIME_WAIT, server收到ACK包后, 状态变为CLOSE
  
     ![wave](https://upload-images.jianshu.io/upload_images/11362584-63aad9661131a2a8.jpeg?imageMogr2/auto-orient/strip|imageView2/2/w/439/format/webp)
  
  clinet需要变为TIME_WAIT等待2MSL(Maximum Segment Lifetime)以确保server收到了client发的ACK包, 因为client在发送ACK包后无法知晓是否server有收到, 如果server没有收到, 就会重发FIN包, 之后client再次发送ACK包再等待2MSL时间, 2MSL是数据包往返的最大时间, 如果2MSL后还没有收到server重发的FIN包, 则表明server收到了ACK包, 2MSL后client状态变为CLOSE
  
  *图片出自 https://www.jianshu.com/p/066d99da7cbd*

#### UDP

与TCP相反, 是一种无连接, 非可靠的通信方式, UDP不保证数据的正确性以及顺序, 但是其传输数据快, 耗费资源少, 通常使用场景如视频通话, 多人游戏中任务位置等数据传输, 即使丢包不会重新发送而是继续往前

### 7.3 网络层

网络层的主要功能就是根据目标IP地址选择如何投递它, 将目标IP和子网掩码做位与运算, 如果得到的结果是自己局域网的地址, 则直接发送给局域网中的目标主机, 否则就寻找下一跳(next hop)路由器, 多次重复这一过程, 数据包最终到达目标主机

#### 7.4 网络接口层

数据链路层两个常用的协议是ARP协议（Address Resolve Protocol, 地址解析协议）和RARP协议（ReverseAddress Resolve Protocol, 逆地址解析协议）. 它们实现了IP地址和机器物理地址（通常是MAC地址, 以太网、令牌环和802.11无线网络都使用MAC地址）之间的相互转换. 

ARP协议原理:

​	主机A的IP地址为192.168.1.1, MAC地址为0A-11-22-33-44-01;

​	主机B的IP地址为192.168.1.2, MAC地址为0A-11-22-33-44-02;

1. 根据主机A上的路由表内容, IP确定用于访问主机B的转发IP地址是192.168.1.2. 然后A主机在自己的本地ARP缓存中检查主机B的匹配MAC地址.
2. 如果主机A在ARP缓存中没有找到映射, 它将询问192.168.1.2的硬件地址, 从而将ARP请求帧广播到本地网络上的所有主机. 源主机A的IP地址和MAC地址都包括在ARP请求中. 本地网络上的每台主机都接收到ARP请求并且检查是否与自己的IP地址匹配. 如果主机发现请求的IP地址与自己的IP地址不匹配, 它将丢弃ARP请求.

   	3. 主机B确定ARP请求中的IP地址与自己的IP地址匹配, 则将主机A的IP地址和MAC地址映射添加到本地ARP缓存中. 
   	4. 主机B将包含其MAC地址的ARP回复消息直接发送回主机A. 
   	5. 当主机A收到从主机B发来的ARP回复消息时, 会用主机B的IP和MAC地址映射更新ARP缓存. 本机缓存是有生存期的, 生存期结束后, 将再次重复上面的过程. 主机B的MAC地址一旦确定, 主机A就能向主机B发送IP通信了. 

在通过上述拿到对应主机或路由器MAC地址后, 通过物理层将包发送出去

```shell
exec 9<> /dev/tcp/www.baidu.com/80
echo -e "GET / HTTP/1.0\n" 1>&9
cat 0<&9
netstat -natp
tcpdump -nn -i {网卡}  // 可通过ifconfig来查看需要抓包的网卡
```

## 8. Redis

跳跃表：是一种多层链表, 最底层是一个有序的链表, 每一层都从上层抽取出来一些关键节点, 这样查找效率就会变成近似二叉查找树, 只不过空间占用也变成了2n, Redis中的Sorted Set就是基于此实现

可以用setnx来做一个分布式锁, setnx即set if not exist, 当要set某个值的时候, 需要先用setnx去设置另外一个值, 这个值就相当于一个锁, 然后setnx之后需要设置expire时间, 防止忘记释放锁等. 但是由于setnx和expire是两个操作不能保证原子性, 因此可以使用 `set name value ex seconds nx`

```shell
set key value [EX seconds] [PX milliseconds] [NX|XX]
EX seconds：设置失效时长，单位秒
PX milliseconds：设置失效时长，单位毫秒
NX：key不存在时设置value，成功返回OK，失败返回(nil)
XX：key存在时设置value，成功返回OK，失败返回(nil)
```

缓存穿透指的是大规模请求一个不存在的值导致超大并发打在DB上, 通常采用参数校验, 设置黑名单, 拉黑IP, 布隆过滤器等方式进行解决

布隆过滤器(BloomFilter): 对一个key进行n次hash, 再将再到数组中n个对应的位置的值设为1, 查找是否存在的时候就再次通过hash去判断所有值是否为1, 这样可以同时节省空间又有很高的查找效率, 缺点就是有一定的误判率, 误判率和hash的次数有关, 因此在创建BloomFilter的时候, 通常需要传入期望误判率以及存入数据量, 通过这两个值去计算数组的长度, 再通过数组长度计算hash次数. 使用BloomFIlter做缓存穿透, 将数据库中待查询的所有的值都放入BloomFilter中, 查询过来后首先通过BloomFilter进行判断是否存在, BloomFilter也可以用来做大数据量的去重等等

缓存雪崩指的是指大量缓存同时过期导致所有请求全部打到DB, 给每个key设置过期时间的时候需要加上一个随机值, 保证不会同时过期, 同时对于热点数据设置永不过期仅仅更新数据

缓存击穿值某个热点数据一值抗着大并发, 突然失效后会导致缓存像穿了一个洞一样, 解决就是设置热点数据永不过期或者对于从数据库获取这个key的操作加一个互斥锁

Redis的持久化分为RDB(Redis Database)和AOF(Append Only File), RDB是将整个redis备份, 而AOF则是备份每一条命令, RDB在bgsave过程中增加的数据是不会写入的, 因此不能保证完整性, AOF则是每条命令都会记录, 因此完整性好但是会影响效率