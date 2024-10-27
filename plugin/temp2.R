library(ggplot2)
data(iris)
head(iris,3)

> ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
+   geom_point()+theme_bw()+
+   labs(title = "Sepal Length vs Sepal Width", .... [TRUNCATED] 
cat: |: No such file or directory
cat: sed: No such file or directory
cat: s/^/# /g: No such file or directory
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point()+theme_bw()+
  labs(title = "Sepal Length vs Sepal Width", x = "Sepal Length", y = "Sepal Width")
  plot.new()

ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point()+theme_bw()+
  labs(title = "Sepal Length vs Sepal Width", x = "Sepal Length", y = "Sepal Width")
  quartz()

ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point()
